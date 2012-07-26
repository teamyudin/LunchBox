Feature: Add new menu
	In order to have multiple menu selection
	As admin user
	I want to be able to manage menus to the application

@mytag
Scenario: Add new menu to repository 
	Given I have selected a menu file from a local drive
	When I press add
	Then repository should contain selected menu
