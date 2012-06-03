#############################################	
#   Configuration Section
#############################################	

$script:projectName = "LunchBox";
$script:targetWebDir="c:\inetpub\wwwroot\LunchBox";
$script:iisFolderName = "IIS:\Sites\Default Web Site\LunchBox\"

Environment "target" -servers @( 
    Server "localhost" @("Web") ;) -installPath "c:\installs\$projectName"

#############################################	

Role "Web" -Incremental {
    write-host "Installing the website"
    
    $destination = $targetWebDir
    
    Set-AppOffline $destination
    
    Delete-Dir $destination 
    
    Copy-Dir web $destination 
    
    Update-WebConfigForProduction "$destination\web.config"
    
    Set-AppOnline $destination
        
	Convert-Folder-To-IIS-Application ($iisFolderName + $projectName)
		
} -FullInstall {
    #Create Appliction User
    #Create IIS Site
    #Set Credentials on App Pool
}


#----------------------------------------------------------------------------------

#function script:Update-NHibernateConfiguration ($filename,$connectionString) {
#        "Updating $filename"
#        $webConfigPath = Resolve-Path $filename
#        $config = New-Object XML 
#        $config.Load($webConfigPath) 
#        $ns = New-Object Xml.XmlNamespaceManager $config.NameTable
#        $ns.AddNamespace( "e", "urn:nhibernate-configuration-2.2" )
#        $config.SelectSingleNode("//e:property[@name = 'connection.connection_string'] ",$ns).innertext = $connectionString
#        $config.Save($webConfigPath) 
#} 

function script:Convert-Folder-To-IIS-Application($iisFolderName){
	Import-Module WebAdministration
	ConvertTo-WebApplication $iisFolderName -ErrorAction SilentlyContinue
}

function script:Delete-Dir($dir){
    if(test-path $dir ){ remove-item $dir -Recurse -Force}
}

function script:Copy-Dir{
    param($source,$destination)
    & xcopy $source $destination /S /I /Y /Q
}

#function script:Load-Data{
#    param($loadDataTestAssembly,$connectionString)
# Update-NHibernateConfiguration "tests/hibernate.cfg.xml" $connectionString
# & "tests\tools\nunit\nunit-console.exe" /include=DataLoader tests\$loadDataTestAssembly
#
#}

function script:Update-WebConfigForProduction {
    param($filename)
    $xml = [xml](get-content $filename)
    $root = $xml.get_DocumentElement();
    $root."system.web".compilation.debug = "false"
    #$root."system.web".customErrors.mode = "RemoteOnly"
    $xml.Save($filename)
}

function script:Set-AppOffline {
    param($destination)
    if(test-path $destination\app_offline.htm.bak){
        rename-item "$destination\app_offline.htm.bak"  "$destination\app_offline.htm" | out-null}
}

function script:Set-AppOnline 
{
    param($destination)
    if(test-path $destination\app_offline.htm){
        rename-item "$destination\app_offline.htm" "$destination\app_offline.htm.bak" | out-null}

}