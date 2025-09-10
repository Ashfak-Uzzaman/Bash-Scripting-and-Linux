$ArtifactsDir="artifacts"
$WorkDir="$ArtifactsDir/workdir"
$IncludeDir="$WorkDir/lib"

if (Test-Path $ArtifactsDir) {
	Remove-Item -Recurse "$ArtifactsDir"
}
New-Item -ItemType Directory -Force "$WorkDir"

dotnet publish --configuration Release

$PublishDir="bin/Release/net6.0-windows/win-x64/publish"

function CreateArchive {
	param (
		$ZipName
	)

	$ZipPath = "$ArtifactsDir/$ZipName"
	./tools/7za.exe a -mx=9 $ZipPath "$WorkDir/*"
	./tools/7za.exe rn $ZipPath $WorkDir "pass-winmenu"
}

Copy-Item "pass-winmenu/$PublishDir/pass-winmenu.exe" "$WorkDir/pass-winmenu.exe"
Copy-Item "pass-winmenu/embedded/default-config.yaml" "$WorkDir/pass-winmenu.yaml"
./tools/7za.exe x -aos "include/GnuPG.zip" "-o$IncludeDir"
./tools/patch.exe --no-backup-if-mismatch "$WorkDir/pass-winmenu.yaml" "include/packaged-config.patch"
CreateArchive "pass-winmenu.zip"

Remove-Item -Recurse "$WorkDir/*"
Copy-Item "pass-winmenu/$PublishDir/pass-winmenu.exe" "$WorkDir/pass-winmenu.exe"
Copy-Item "pass-winmenu/embedded/default-config.yaml" "$WorkDir/pass-winmenu.yaml"
./tools/patch.exe --no-backup-if-mismatch "$WorkDir/pass-winmenu.yaml" "include/packaged-config-nogpg.patch"
CreateArchive "pass-winmenu-nogpg.zip"

Copy-Item "pass-winmenu/$PublishDir/pass-winmenu.exe" "$ArtifactsDir/pass-winmenu.exe"
Copy-Item "commandline/$PublishDir/pw.exe" "$ArtifactsDir/pw.exe"