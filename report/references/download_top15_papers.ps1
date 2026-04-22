$ErrorActionPreference = 'Stop'
Set-Location (Join-Path $PSScriptRoot '..\..')

$papersDir = 'report/references/papers'
if (-not (Test-Path $papersDir)) {
  New-Item -ItemType Directory -Path $papersDir | Out-Null
}
Get-ChildItem -Path $papersDir -File -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue

$refs = @{
  1 = @{Title='Gamification in Mobile Learning Enhancing Engagement and Retention'; Url='https://www.researchgate.net/publication/397094450_Gamification_in_Mobile_Learning_Enhancing_Engagement_and_Retention_through_Interactive_Design'}
  2 = @{Title='Impact of Gamification Techniques on Learner Engagement Motivation and Retention'; Url='https://academic-publishing.org/index.php/ejel/article/download/3563/2314'}
  3 = @{Title='Impact of Educational Games on Learning Outcomes'; Url='https://www.researchgate.net/publication/377522721_The_Impact_of_Educational_Games_on_Learning_Outcomes'}
  4 = @{Title='Instructional Design and Usability for Branching Model'; Url='https://pmc.ncbi.nlm.nih.gov/articles/PMC10276579/'}
  5 = @{Title='Serious Games to Teach Ethics'; Url='https://csuepress.columbusstate.edu/cgi/viewcontent.cgi?article=2055&context=bibliography_faculty'}
  6 = @{Title='Effect of Multimedia on Vocabulary Learning and Retention'; Url='https://www.researchgate.net/publication/382711394_The_Effect_of_Multimedia_on_Vocabulary_Learning_and_Retention'}
  7 = @{Title='START Sanskrit Teaching Annotation and Recitation'; Url='https://aclanthology.org/2024.iscls-1.9.pdf'}
  8 = @{Title='Text to Speech Tools and Reading Comprehension Meta Analysis'; Url='https://pmc.ncbi.nlm.nih.gov/articles/PMC5494021/'}
  9 = @{Title='Master Scripture Memorization Bible Memory Apps'; Url='https://www.faithgpt.io/blog/best-bible-memory-apps-2025'}
  10 = @{Title='Digital Tools on Vocabulary Development in Second Language Learning'; Url='https://www.researchgate.net/publication/385940762_The_Impact_of_Digital_Tools_on_Vocabulary_Development_in_Second_Language_Learning'}
  11 = @{Title='From Kurukshetra to Classroom Applying Gita Teachings'; Url='https://ukrpublisher.com/wp-content/uploads/2026/01/UKRJEL-285-2026.pdf'}
  12 = @{Title='Impact of Gamified Learning on Students Learning Engagement'; Url='https://www.sciencepublishinggroup.com/article/10.11648/j.edu.20251406.12'}
  13 = @{Title='Vocabulary Acquisition in Print vs Digital Media'; Url='https://www.mdpi.com/2079-8954/11/1/30'}
  14 = @{Title='Effectiveness of Gamification in Educational Settings Meta Analysis'; Url='https://pmc.ncbi.nlm.nih.gov/articles/PMC10591086/'}
  15 = @{Title='Gamification in Education and Student Academic Performance'; Url='https://www.mdpi.com/1999-4893/19/2/143'}
  16 = @{Title='Gamification in Mobile Assisted Language Learning'; Url='https://www.tandfonline.com/doi/full/10.1080/09588221.2021.1933540'}
  17 = @{Title='Gamification and Student Engagement and Learning Outcomes'; Url='https://www.researchgate.net/publication/391699885_The_Impact_of_Gamification_on_Student_Engagement_and_Learning_Outcomes'}
  18 = @{Title='Gamification Influence on Motivation and Cognitive Load'; Url='https://www.mdpi.com/2227-7102/14/10/1115'}
  19 = @{Title='Serious Video Games Tools for Learning Training and Health'; Url='https://www.mdpi.com/2673-8392/6/4/83'}
  20 = @{Title='What do we Evaluate in Serious Games Systematic Review'; Url='https://repositorio.tec.mx/bitstreams/382cc36c-c43c-4f2d-aa2e-9880deada241/download'}
  21 = @{Title='Serious Games for Knowledge and Self Management Meta Analysis'; Url='https://www.researchgate.net/publication/280116561_Serious_Games_for_improving_knowledge_and_self-management_in_young_people_with_chronic_conditions_A_systematic_review_and_meta-analysis'}
  22 = @{Title='Digital Serious Games for Undergraduate Nursing Education'; Url='https://www.mdpi.com/2078-2489/16/10/877'}
  23 = @{Title='Why Memorize Scripture with Smartphones'; Url='https://www.desiringgod.org/articles/we-have-smartphones-why-memorize-scripture'}
  24 = @{Title='Serious game Responsible Conduct of Research'; Url='https://teaching-and-learning-collection.sites.uu.nl/project/serious-game-responsible-conduct-of-research/'}
  25 = @{Title='Wisdom in Higher Education using Bhagavad Gita'; Url='https://www.emerald.com/qrj/article/22/3/325/359484'}
  26 = @{Title='Psychology of Hot Streak Game Design'; Url='https://uxmag.medium.com/the-psychology-of-hot-streak-game-design-how-to-keep-players-coming-back-every-day-without-shame-3dde153f239c'}
  27 = @{Title='Gamified and NLP Enhanced Adaptive Learning Platform'; Url='https://www.cureusjournals.com/articles/3705-evaluating-the-effectiveness-of-a-gamified-and-nlp-enhanced-adaptive-learning-platform-for-engineering-education'}
  28 = @{Title='Impact of Streak Feature on Kindergarten Numeracy'; Url='https://www.researchgate.net/publication/400916338_Impact_of_streak_feature_in_gamified_app_on_kindergarten_numeracy_skills'}
  29 = @{Title='Learning English Words of Sanskrit Origin'; Url='https://files.eric.ed.gov/fulltext/EJ1401069.pdf'}
  30 = @{Title='New Approach to Learning Sanskrit Using ChatGPT'; Url='https://www.researchgate.net/publication/402609369_A_New_Approach_To_Learning_Sanskrit_Using_ChatGPT_Analyzing_Its_Advantages_And_Disadvantages'}
  31 = @{Title='Impact of Bhagavad Gita Teachings on Cognitive Development'; Url='https://ijirt.org/publishedpaper/IJIRT191643_PAPER.pdf'}
}

$priority = @(16,14,4,8,7,2,13,20,22,5,29,31,18,15,19,6,10,12,27,11,25,21,17,3,1,30,28,24,23,9,26)

function Test-IsPdf([string]$path) {
  if (-not (Test-Path $path)) { return $false }
  $bytes = [System.IO.File]::ReadAllBytes($path)
  if ($bytes.Length -lt 4) { return $false }
  $header = [System.Text.Encoding]::ASCII.GetString($bytes[0..3])
  return $header -eq '%PDF'
}

function Sanitize-Name([string]$text) {
  $name = $text -replace '[^A-Za-z0-9 ]', ' '
  $name = ($name -replace '\s+', ' ').Trim()
  if ($name.Length -gt 70) { $name = $name.Substring(0, 70).Trim() }
  return $name
}

function Build-TryUrls([string]$url) {
  $list = New-Object System.Collections.Generic.List[string]
  if ($url.ToLower().EndsWith('.pdf')) { $list.Add($url) | Out-Null }
  if ($url -match 'pmc\.ncbi\.nlm\.nih\.gov/articles/') { $list.Add(($url.TrimEnd('/') + '/pdf')) | Out-Null }
  if ($url -match 'mdpi\.com/') { $list.Add(($url.TrimEnd('/') + '/pdf')) | Out-Null }
  if ($url -match 'tandfonline\.com/doi/full/') { $list.Add(($url -replace '/doi/full/', '/doi/pdf/')) | Out-Null }
  $list.Add($url) | Out-Null
  return $list | Select-Object -Unique
}

$selected = New-Object System.Collections.Generic.List[object]
$failed = New-Object System.Collections.Generic.List[object]
$attempted = 0

foreach ($ref in $priority) {
  if ($selected.Count -ge 15) { break }

  $title = [string]$refs[$ref].Title
  $url = [string]$refs[$ref].Url
  $tryUrls = Build-TryUrls $url
  $attempted += 1
  $downloaded = $false
  $lastError = ''

  foreach ($u in $tryUrls) {
    $tmp = Join-Path $papersDir ("tmp-ref$ref.bin")
    try {
      Invoke-WebRequest -Uri $u -OutFile $tmp -MaximumRedirection 10 -TimeoutSec 90 -Headers @{ 'User-Agent' = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)' } | Out-Null
      if (Test-IsPdf $tmp) {
        $rank = $selected.Count + 1
        $fileBase = Sanitize-Name $title
        $fileName = ('{0:D2}-ref{1}-{2}.pdf' -f $rank, $ref, $fileBase)
        $dest = Join-Path $papersDir $fileName
        Move-Item -Path $tmp -Destination $dest -Force

        $selected.Add([pscustomobject]@{
          Rank = $rank
          Ref = $ref
          Title = $title
          SourceUrl = $url
          DownloadedFrom = $u
          FileName = $fileName
        }) | Out-Null

        $downloaded = $true
        break
      }

      Remove-Item -Path $tmp -Force -ErrorAction SilentlyContinue
      $lastError = 'response is not a pdf'
    }
    catch {
      Remove-Item -Path $tmp -Force -ErrorAction SilentlyContinue
      $lastError = $_.Exception.Message
    }
  }

  if (-not $downloaded) {
    $failed.Add([pscustomobject]@{
      Ref = $ref
      Title = $title
      Url = $url
      Reason = $lastError
    }) | Out-Null
  }
}

$reportPath = 'report/references/TOP_15_PAPERS.md'
$lines = New-Object System.Collections.Generic.List[string]
$lines.Add('# Top 15 selected research papers for LearnGeeta') | Out-Null
$lines.Add('') | Out-Null
$lines.Add('These papers were selected for direct relevance to the app''s live features: gamified practice, Sanskrit learning flow, branching ethics games, TTS-based support, and XP/streak progression.') | Out-Null
$lines.Add('') | Out-Null
$lines.Add('## Selected papers') | Out-Null
$lines.Add('') | Out-Null
$lines.Add('| Rank | Ref # | Title | Source URL | Saved file | Status |') | Out-Null
$lines.Add('|---|---:|---|---|---|---|') | Out-Null
foreach ($s in $selected) {
  $lines.Add("| $($s.Rank) | $($s.Ref) | $($s.Title) | $($s.SourceUrl) | $($s.FileName) | downloaded |") | Out-Null
}
$lines.Add('') | Out-Null
$lines.Add('## Attempted but not downloaded') | Out-Null
$lines.Add('') | Out-Null
if ($failed.Count -eq 0) {
  $lines.Add('- None') | Out-Null
}
else {
  foreach ($f in $failed) {
    $reason = [string]$f.Reason
    if ([string]::IsNullOrWhiteSpace($reason)) { $reason = 'download failed' }
    $lines.Add("- Ref $($f.Ref): $($f.Title) - $reason") | Out-Null
  }
}

$lines | Set-Content -Path $reportPath -Encoding utf8

$pdfCount = (Get-ChildItem -Path $papersDir -File | Measure-Object).Count
Write-Host "Attempted: $attempted"
Write-Host "Downloaded valid PDFs: $($selected.Count)"
Write-Host "Files currently in papers dir: $pdfCount"
Write-Host "Report: $reportPath"
if ($selected.Count -lt 15) {
  Write-Host 'WARNING: fewer than 15 PDFs were downloaded from the provided links.'
}
