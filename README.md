# AeroSQL-DB
  Programs used for generating and easily access a public airfoil database with tons of aerodynamic data

<h1>Description</h1>

  To make aerodynamic force and moment calculations it's often required to posses 2D airfoil aerodynamic coefficients, usually the best the quality of the data is, the best is the 
final result. Unfortunally this data is only obtained by tons experiments, wich results (if exists) are spreaded across the internet through a lot of documents, in a hard to consume 
way, like scanned NACA Reports, or it's calculated by solvers like Xfoil, wich can take a lot of effort and time if you're willing to do this calculations through a variety of Reynolds
and Mach numbers.

 As a solution to that problem, it's proposed to maintain an 2D airfoil public database capable of retaining data from various sources and present it in a more consumable way, making the process of manually typing NACA Reports results or xfoil calculation an one-time-thing.
 
 To make this more suitable, it is pre-populated with all airfoil geometries from UIUC database (link below) and they aerodynamic coefficients for a vast range of Reynolds and Mach numbers
 together with an method for extending their alfa range up to 110° using Björn Montgomerie method.
 
 More detail in the document 'Banco de dados muti-plataforma de coeficientes aerodinâmicos de baixo Reynolds para ângulos de ataque estendidos com dependência de Mach.pdf' contained
 in the repository, and in the youtube link below:
 
 https://www.youtube.com/watch?v=DbpSJpwQThg
 
 https://m-selig.ae.illinois.edu/ads/coord_database.html

<h1>Usage</h1>

The database can be accessed through any mysql connector available for the programing language you chose (more details on the connectors and APIs in https://www.mysql.com/products/connector/), 
but this repository it's shipped with pre made scripts that helps to access and visualize and download the data in it using python or matlab, wich will be covered next.

<h2>Matlab database access scripts</h2>

For the matlab script it's necessary to download the mysql ODBC driver that can be found on https://dev.mysql.com/downloads/connector/odbc/5.3.html and configure it following this steps:

<h3>1: Open windows administrative tools</h3>

Open windows search bar and search for windows administrative tools

<h3>2: Open ODBC Data Sources </h3>

Click on ODBC Data Sources (32 or 64bit)

<h3>3: Add an new system data source</h3>

Click on System DSN tab and then click on "add" buttom

<h3>4: Fill the form according to the image below</h3>

Click on MySQL ODBC 5.3 Unicode driver and fill the forms on the next window as below:

[MySQL connector information](./docs/MySQL_connector_inf.png) 
