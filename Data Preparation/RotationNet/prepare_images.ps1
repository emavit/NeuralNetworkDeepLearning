$dataset = $args[0]
$output = $args[1]

New-Item -ItemType Directory -Path "$output\train"
New-Item -ItemType Directory -Path "$output\test"
New-Item -ItemType Directory -Path "$output\validation"

$classes = Get-ChildItem $dataset
foreach ($cls in $classes) {
    $subsets = Get-ChildItem "$dataset\$cls"

    foreach ($subset in $subsets) {
        $outputSubsetPath = "$output\$subset\$cls"
        New-Item -ItemType Directory -Path $outputSubsetPath

        $files = Get-ChildItem "$dataset\$cls\$subset" -Filter "*.png"

        foreach ($file in $files) {
            Copy-Item -Path $file.FullName -Destination $outputSubsetPath
        }
    }
}