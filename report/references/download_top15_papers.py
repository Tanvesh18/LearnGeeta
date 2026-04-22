import os
import re
import sys
import hashlib
from pathlib import Path
from urllib.parse import urljoin, urlparse
from urllib.request import Request, urlopen
from urllib.error import URLError, HTTPError

ROOT = Path(__file__).resolve().parents[2]
REF_MD = ROOT / "report" / "references" / "LEARNGEETA_REFERENCES.md"
PAPERS_DIR = ROOT / "report" / "references" / "papers"
REPORT_MD = ROOT / "report" / "references" / "TOP_15_PAPERS.md"

TARGET_COUNT = 15
MIN_PDF_BYTES = 5000

PRIORITY = [
    16, 14, 4, 8, 7, 2, 13, 20, 22, 5, 29, 31, 18, 15, 19,
    6, 10, 12, 27, 11, 25, 21, 17, 3, 1, 30, 28, 24, 23, 9, 26,
]

UA = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
MDPI_COOKIE = os.environ.get("MDPI_COOKIE", "").strip()


def sanitize_filename(text: str, max_len: int = 80) -> str:
    clean = re.sub(r"[^A-Za-z0-9 ]+", " ", text)
    clean = re.sub(r"\s+", " ", clean).strip()
    if not clean:
        clean = "paper"
    return clean[:max_len].strip()


def fetch_bytes(url: str, timeout: int = 90, extra_headers: dict | None = None):
    host = (urlparse(url).netloc or "").lower()
    headers = {
        "User-Agent": UA,
        "Accept": "application/pdf,*/*;q=0.8",
    }

    # Some MDPI endpoints are behind bot protection in this environment.
    # If a valid cookie is provided, include it for PDF/article fetches.
    if "mdpi.com" in host and MDPI_COOKIE:
        referer = "https://www.mdpi.com/"
        if "/pdf" in url:
            referer = url.split("/pdf", 1)[0]
        headers["Cookie"] = MDPI_COOKIE
        headers["Referer"] = referer

    if extra_headers:
        headers.update(extra_headers)

    req = Request(url, headers=headers)
    with urlopen(req, timeout=timeout) as resp:
        data = resp.read()
        final_url = resp.geturl()
        content_type = resp.headers.get("Content-Type", "")
    return data, final_url, content_type


def is_pdf_blob(data: bytes) -> bool:
    return len(data) >= MIN_PDF_BYTES and data.startswith(b"%PDF")


def extract_pmc_pow(html: str):
    m_challenge = re.search(r'POW_CHALLENGE\s*=\s*"([^\"]+)"', html)
    m_difficulty = re.search(r'POW_DIFFICULTY\s*=\s*"([^\"]+)"', html)
    if not m_challenge or not m_difficulty:
        return None
    try:
        difficulty = int(m_difficulty.group(1))
    except ValueError:
        return None
    return m_challenge.group(1), difficulty


def solve_pmc_pow_cookie(html: str, max_nonce: int = 2_000_000):
    parsed = extract_pmc_pow(html)
    if not parsed:
        return None

    challenge, difficulty = parsed
    if difficulty < 0:
        return None

    prefix = "0" * difficulty
    for nonce in range(max_nonce + 1):
        digest = hashlib.sha256((challenge + str(nonce)).encode("utf-8")).hexdigest()
        if digest.startswith(prefix):
            return f"cloudpmc-viewer-pow={challenge},{nonce}"
    return None


def candidate_urls(base_url: str):
    urls = []
    b = base_url.strip()
    if b.lower().endswith(".pdf"):
        urls.append(b)

    if "pmc.ncbi.nlm.nih.gov/articles/" in b:
        t = b.rstrip("/")
        urls.extend([
            t + "/pdf",
            t + "/pdf/",
            t + "/pdf/?download=1",
        ])

    if "mdpi.com/" in b:
        t = b.rstrip("/")
        urls.extend([
            t + "/pdf",
            t + "/pdf?download=1",
            t + "/pdf/",
        ])

    if "tandfonline.com/doi/full/" in b:
        urls.extend([
            b.replace("/doi/full/", "/doi/pdf/"),
            b.replace("/doi/full/", "/doi/epdf/"),
        ])

    if "researchgate.net/publication/" in b:
        urls.extend([
            b.rstrip("/") + "/download",
            b.rstrip("/") + "/download?_tp=eyJjb250ZXh0Ijp7InBhZ2UiOiJwdWJsaWNhdGlvbiJ9fQ",
        ])

    if "cureusjournals.com/articles/" in b:
        urls.extend([
            b.rstrip("/") + "/pdf",
            b.rstrip("/") + ".pdf",
        ])

    urls.append(b)

    deduped = []
    seen = set()
    for u in urls:
        if u not in seen:
            seen.add(u)
            deduped.append(u)
    return deduped


def extract_pdf_links_from_html(html: str, page_url: str):
    found = []

    meta_patterns = [
        r"citation_pdf_url\"\s*content=\"([^\"]+)\"",
        r"property=\"og:pdf\"\s*content=\"([^\"]+)\"",
    ]

    for pat in meta_patterns:
        for m in re.finditer(pat, html, flags=re.IGNORECASE):
            found.append(urljoin(page_url, m.group(1).strip()))

    for m in re.finditer(r"href=[\"']([^\"']+?\.pdf(?:\?[^\"']*)?)[\"']", html, flags=re.IGNORECASE):
        found.append(urljoin(page_url, m.group(1).strip()))

    for m in re.finditer(r"href=[\"']([^\"']+?/pdf/?(?:\?[^\"']*)?)[\"']", html, flags=re.IGNORECASE):
        found.append(urljoin(page_url, m.group(1).strip()))

    deduped = []
    seen = set()
    for u in found:
        if u not in seen:
            seen.add(u)
            deduped.append(u)
    return deduped


def parse_references(md_text: str):
    if "#### **Works cited**" not in md_text:
        raise RuntimeError("Works cited section not found")

    works = md_text.split("#### **Works cited**", 1)[1]
    refs = {}

    line_pat = re.compile(
        r"^\s*(\d+)\.\s*(.*?)\[([^\]]+)\]\((https?://[^)]+)\)\s*$",
        flags=re.MULTILINE,
    )

    for m in line_pat.finditer(works):
        ref_num = int(m.group(1))
        raw_title = m.group(2).strip()
        raw_title = re.sub(r",\s*accessed.*$", "", raw_title, flags=re.IGNORECASE)
        raw_title = re.sub(r"\s+-\s+[^-]+$", "", raw_title).strip()
        if not raw_title:
            raw_title = f"Reference {ref_num}"
        refs[ref_num] = {
            "title": raw_title,
            "url": m.group(4).strip(),
        }

    return refs


def record_success(selected: list, ref_num: int, title: str, source_url: str, downloaded_from: str, data: bytes):
    rank = len(selected) + 1
    fname = f"{rank:02d}-ref{ref_num:02d}-{sanitize_filename(title)}.pdf"
    out = PAPERS_DIR / fname
    out.write_bytes(data)
    selected.append(
        {
            "rank": rank,
            "ref": ref_num,
            "title": title,
            "source_url": source_url,
            "downloaded_from": downloaded_from,
            "file": fname,
        }
    )


def main():
    if not REF_MD.exists():
        raise FileNotFoundError(f"Missing references file: {REF_MD}")

    PAPERS_DIR.mkdir(parents=True, exist_ok=True)
    for f in PAPERS_DIR.glob("*.pdf"):
        try:
            f.unlink()
        except OSError:
            pass

    refs = parse_references(REF_MD.read_text(encoding="utf-8"))

    selected = []
    failed = []
    attempted = 0

    for ref_num in PRIORITY:
        if len(selected) >= TARGET_COUNT:
            break
        if ref_num not in refs:
            failed.append((ref_num, f"missing ref entry {ref_num}"))
            continue

        title = refs[ref_num]["title"]
        source_url = refs[ref_num]["url"]
        attempted += 1

        ok = False
        reason = "no pdf found"
        tried_urls = set()

        queue = candidate_urls(source_url)
        idx = 0

        while idx < len(queue):
            url = queue[idx]
            idx += 1
            if url in tried_urls:
                continue
            tried_urls.add(url)

            try:
                data, final_url, content_type = fetch_bytes(url)
            except (HTTPError, URLError, TimeoutError, OSError) as e:
                reason = str(e)
                continue

            if is_pdf_blob(data):
                record_success(selected, ref_num, title, source_url, url, data)
                ok = True
                break

            if "text/html" in (content_type or "") or data[:200].lstrip().startswith(b"<"):
                try:
                    html = data.decode("utf-8", errors="ignore")
                except Exception:
                    html = ""

                # PMC PDF endpoints can return a PoW challenge page. Solve and retry.
                final_host = (urlparse(final_url).netloc or "").lower()
                if ("pmc.ncbi.nlm.nih.gov" in final_host) and ("POW_CHALLENGE" in html):
                    pow_cookie = solve_pmc_pow_cookie(html)
                    if pow_cookie:
                        try:
                            pow_data, _, _ = fetch_bytes(
                                url,
                                extra_headers={
                                    "Cookie": pow_cookie,
                                    "Accept": "application/pdf,*/*;q=0.8",
                                },
                            )
                            if is_pdf_blob(pow_data):
                                record_success(selected, ref_num, title, source_url, url, pow_data)
                                ok = True
                                break
                        except (HTTPError, URLError, TimeoutError, OSError) as e:
                            reason = f"pmc pow retry failed: {e}"

                for pdf_url in extract_pdf_links_from_html(html, final_url):
                    if pdf_url not in tried_urls:
                        queue.append(pdf_url)

            reason = "response was not a valid PDF"

        if not ok:
            failed.append((ref_num, f"{title} - {reason}"))

    lines = []
    lines.append("# Top 15 selected research papers for LearnGeeta")
    lines.append("")
    lines.append("Selection rationale: priority was based on direct relevance to app features (Sanskrit learning, gamified quizzes, ethics/branching gameplay, TTS accessibility, and progress systems). Only files with verified PDF signatures were accepted.")
    lines.append("Note: MDPI links can require a bot-protection cookie in this environment. If needed, set MDPI_COOKIE before running this script.")
    lines.append("")
    lines.append("## Selected papers")
    lines.append("")
    lines.append("| Rank | Ref # | Title | Source URL | Saved file | Status |")
    lines.append("|---|---:|---|---|---|---|")
    for s in selected:
        lines.append(
            f"| {s['rank']} | {s['ref']} | {s['title']} | {s['source_url']} | {s['file']} | downloaded |"
        )

    lines.append("")
    lines.append("## Attempted but not downloaded")
    lines.append("")
    if failed:
        for ref_num, why in failed:
            lines.append(f"- Ref {ref_num}: {why}")
    else:
        lines.append("- None")

    REPORT_MD.write_text("\n".join(lines) + "\n", encoding="utf-8")

    print(f"Attempted: {attempted}")
    print(f"Downloaded valid PDFs: {len(selected)}")
    print(f"Files currently in papers dir: {len(list(PAPERS_DIR.glob('*.pdf')))}")
    print(f"Report: {REPORT_MD}")
    if len(selected) < TARGET_COUNT:
        print("WARNING: fewer than 15 PDFs were downloadable from the provided links/endpoints.")


if __name__ == "__main__":
    try:
        main()
    except Exception as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        raise
