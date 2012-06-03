# required parameters :
# 	$db_smartrules_name

properties {
	$projectName = "LunchBox"
	$solutionName = "LunchBox"
	
	if(-not $version)
    {
        $version = "1.0.0.0"
    }
	
    $projectConfig = "Release"
	$base_dir = resolve-path .\
	$source_dir = "$base_dir\src"
    $nunitPath = "$source_dir\packages\NUnit.Runners.2.6.0.12051\tools\"
	
	$build_dir = "$base_dir\build"
	$test_dir = "$build_dir\test"
	$testCopyIgnorePath = "_ReSharper"
	$package_dir = "$build_dir\package"	
	$package_file = "$build_dir\latestVersion\" + $projectName +"_Package.zip"
	
	$db_server = ".\SQLEXPRESS"
	$databaseserver = ".\SQLEXPRESS"
    $database_name = "DBNAME"
	$database_scripts_dir = "$source_dir\Database\" + $database_name
	$connection_string = "server=$databaseserver;database=$databasename;Integrated Security=true;"	
	
	$unitTestAssembly = "UnitTests.dll"
    $integrationTestAssembly = "IntegrationTests.dll"
    $fullSystemTestAssembly = "FullSystemTests.dll"
	
	$cassini_app = 'C:\Program Files (x86)\Common Files\Microsoft Shared\DevServer\10.0\WebDev.WebServer40.EXE'
	$port = 1234
	$webapp_dir = "$source_dir\UI" 
	
	$pstrami_dir = "$base_dir\pstrami"	

}

$framework = '4.0'

task default -depends Init, CommonAssemblyInfo, Compile, Package
task ci -depends Init, CommonAssemblyInfo, Compile, Test, Package

task Init {
    delete_file $package_file
    delete_directory $build_dir
    create_directory $test_dir
	create_directory $build_dir
}

task ConnectionString {
	$connection_string = "server=$db_server;database=$database_name;Integrated Security=true;"
	write-host "Using connection string: $connection_string"
	#poke-xml $hibernateConfig "//e:property[@name = 'connection.connection_string']" $connection_string @{"e" = "urn:nhibernate-configuration-2.2"}
}

task Compile -depends Init {
    msbuild /t:clean /v:q /nologo /p:Configuration=$projectConfig $source_dir\$solutionName.sln
    delete_file $error_dir
    msbuild /t:build /v:q /nologo /p:Configuration=$projectConfig $source_dir\$solutionName.sln
}

task Test {
	copy_all_assemblies_for_test $test_dir
	exec {
		& $nunitPath\nunit-console.exe $test_dir\$unitTestAssembly /nologo /nodots /xml=$build_dir\TestResult.xml    
	}
}

task CommonAssemblyInfo {
    $version = "1.0.0.0"   
    create-commonAssemblyInfo "$version" $projectName "$source_dir\CommonAssemblyInfo.cs"
}

task Package -depends Compile {
    delete_directory $package_dir
    copy_website_files "$webapp_dir" "$package_dir\web"
	copy_files "$pstrami_dir" "$package_dir"
	"pstrami.bat deploy-package target . 1 & pause"  | out-file "$package_dir\click_to_install.bat" -encoding "ASCII"
	"pstrami.bat deploy-package target . 0 & pause"  | out-file "$package_dir\click_to_upgrade.bat" -encoding "ASCII"
	zip_directory $package_dir $package_file 
}

task FullSystemTests -depends Compile, RebuildDatabase {
    copy_all_assemblies_for_test $test_dir
    &$cassini_app "/port:$port" "/path:$webapp_dir"
    & $nunitPath\nunit-console-x86.exe $test_dir\$fullSystemTestAssembly /framework=net-4.0 /nologo /nodots /xml=$build_dir\FullSystemTestResult.xml
    exec { taskkill  /F /IM WebDev.WebServer40.EXE }
}
 
function global:zip_directory($directory,$file) {
    write-host "Zipping folder: " $test_assembly
    delete_file $file
    cd $directory
    & "$base_dir\7zip\7za.exe" a -mx=9 -r $file
    cd $base_dir
}

function global:copy_website_files($source,$destination){
    $exclude = @('*.user','*.dtd','*.tt','*.cs','*.csproj','*.orig', '*.log') 
    copy_files $source $destination $exclude
	delete_directory "$destination\obj"
}

function global:copy_files($source,$destination,$exclude=@()){    
    create_directory $destination
    Get-ChildItem $source -Recurse -Exclude $exclude | Copy-Item -Destination {Join-Path $destination $_.FullName.Substring($source.length)} 
}

function global:Copy_and_flatten ($source,$filter,$dest) {
  ls $source -filter $filter  -r | Where-Object{!$_.FullName.Contains("$testCopyIgnorePath") -and !$_.FullName.Contains("packages") }| cp -dest $dest -force
}

function global:copy_all_assemblies_for_test($destination){
  create_directory $destination
  Copy_and_flatten $source_dir *.exe $destination
  Copy_and_flatten $source_dir *.dll $destination
  Copy_and_flatten $source_dir *.config $destination
  Copy_and_flatten $source_dir *.xml $destination
  Copy_and_flatten $source_dir *.pdb $destination
  Copy_and_flatten $source_dir *.sql $destination
  Copy_and_flatten $source_dir *.xlsx $destination
}

function global:delete_file($file) {
    if($file) { remove-item $file -force -ErrorAction SilentlyContinue | out-null } 
}

function global:delete_directory($directory_name)
{
  rd $directory_name -recurse -force  -ErrorAction SilentlyContinue | out-null
}

function global:delete_files_in_dir($dir)
{
	get-childitem $dir -recurse | foreach ($_) {remove-item $_.fullname}
}

function global:create_directory($directory_name)
{
  mkdir $directory_name  -ErrorAction SilentlyContinue  | out-null
}

function global:create-commonAssemblyInfo($version,$applicationName,$filename)
{
"using System.Reflection;
using System.Runtime.InteropServices;

//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated by a tool.
//     Runtime Version:2.0.50727.4927
//
//     Changes to this file may cause incorrect behavior and will be lost if
//     the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

[assembly: ComVisibleAttribute(false)]
[assembly: AssemblyVersionAttribute(""$version"")]
[assembly: AssemblyFileVersionAttribute(""$version"")]
[assembly: AssemblyCopyrightAttribute(""Copyright 2010"")]
[assembly: AssemblyProductAttribute(""$applicationName"")]
[assembly: AssemblyCompanyAttribute(""Headspring"")]
[assembly: AssemblyConfigurationAttribute(""release"")]
[assembly: AssemblyInformationalVersionAttribute(""$version"")]"  | out-file $filename -encoding "ASCII"    
}

function script:poke-xml($filePath, $xpath, $value, $namespaces = @{}) {
    [xml] $fileXml = Get-Content $filePath
    
    if($namespaces -ne $null -and $namespaces.Count -gt 0) {
        $ns = New-Object Xml.XmlNamespaceManager $fileXml.NameTable
        $namespaces.GetEnumerator() | %{ $ns.AddNamespace($_.Key,$_.Value) }
        $node = $fileXml.SelectSingleNode($xpath,$ns)
    } else {
        $node = $fileXml.SelectSingleNode($xpath)
    }
    
    Assert ($node -ne $null) "could not find node @ $xpath"
        
    if($node.NodeType -eq "Element") {
        $node.InnerText = $value
    } else {
        $node.Value = $value
    }

    $fileXml.Save($filePath) 
} 
