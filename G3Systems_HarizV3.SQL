------------------------------------------------
--------- G3 SYSTEMS ---------------------------
	------------------------------------------------
	-----SKAPAT AV HARIZ@KTH.se 2020 ---------------
	---- NEWTONS YRKESHÖGSKOLA ---------------------
	---- PROJEKTARBETE TILL DATABASKURSEN-----------
	------------------------------------------------
	------------------------------------------------

------------------------------------------------------------------------
	-----KVAR ATT GÖRA------------------------------------------------------
	-- Kolla ifall alla Entity tabeller finns
	-- kolla ifall alla Sambands Tabeller finns
	-- Sätt cascade överallt

	---Sätt in alla Nycklar i nyckelraden
	-- Sätt in alla referensattribut i referensattributraden, Så det blir snyggt uppdelat

	-- Skapa dom viktigaste viewsen . Dvs maintabellerna (tabell+aggregatkolonner. Tex Total cash i building)
	-- Skriv om allt till engelska
	------------------------------------------------------------------------
------------------------------------------------------------------------
----Datatyper: (Använder alltid value som nyckelord)
--------------------------------------------------------------------------
--------------------------------------------------------------------------
	--CREATE TYPE PINT AS INT 
		--	default 0,
		--	CHECK(value >= 0);
	--CREATE TYPE VARCHAR(50) NOT NULL DEFAULT 'UNNAMED' AS varchar(50)  --Slipper kopiera villkor för namn
		--	default "Unnamed",
		--	CHECK (value NOT NULL);
	--CREATE TYPE BIT NOT NULL DEFAULT 1 AS bit  -- Default True
		--	default 1,
		--	CHECK (value NOT NULL);
	--CREATE TYPE BIT NOT NULL DEFAULT 1FALSE AS bit  -- Default FALSE
		--	default 0,
		--	CHECK (value NOT NULL);
	--CREATE TYPE PERCENT AS INT  -- Default True
		--	default 0,
		--	CHECK (value =< 100 AND value >=0);
	----Potentiel inkapsling av ID-typer
		--	--CREATE DOMAIN IDTYPE AS INT  -- Default True
		--	--	CHECK (value NOT NULL),
		--	--	constraint UNIQUE (value);

------------------------------------------------------------------------
--- SQL DEFINITIONSFILE ------------------------------------------------
------------------------------------------------------------------------

CREATE TABLE Buildings(
	Building INT IDENTITY(1,1) PRIMARY KEY NOT NULL, 
	BuildingName VARCHAR(50) NOT NULL DEFAULT 'UNNAMED',
	
	Activated BIT NOT NULL DEFAULT 1,
	Visible BIT NOT NULL DEFAULT 1,

	--Nycklar:
	-- 
	-- Beräknade attribut nedan
	--TotalCash INT NOT NULL, (SUM aggregat av alla betalda ordrar)

	--Referensattribut nedan
	-- 
	--Extra Begränsningar nedan
	--
	);
CREATE TABLE Terminals(
	Terminal INT IDENTITY(1,1)  NOT NULL PRIMARY KEY,
	TerminalName VARCHAR(50) NOT NULL DEFAULT 'UNNAMED',
	Building INT FOREIGN KEY REFERENCES Buildings(Building),
	Activated BIT NOT NULL DEFAULT 1,
	Visible BIT NOT NULL DEFAULT 1,

	--Nycklar:

	-- Beräknade attribut nedan
	--
	Ledig BIT NOT NULL DEFAULT 1,
	-- Referensattribut nedan
	--
	-- Extra Begränsningar nedan
	--
	);
CREATE TABLE Infoscreens(
	Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY ,
	Building INT FOREIGN KEY REFERENCES Buildings(Building),

	Activated BIT NOT NULL DEFAULT 1,
	Visible BIT NOT NULL DEFAULT 1,

	--Nycklar:

	-- Beräknade attribut nedan
	--
	-- Referensattribut nedan
	--
	-- Extra Begränsningar nedan
	--
	);
CREATE TABLE StationTypes(
	StationType INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	StationTypeName VARCHAR(50) ,
	Activated BIT NOT NULL DEFAULT 1,
	Visible BIT NOT NULL DEFAULT 1,
	DangerLevel INT NOT NULL DEFAULT 0

	--Nycklar:

	--Beräknade attribut nedan
	--
	-- Referensattribut nedan
	-- Extra Begränsningar nedan
	--
	);
CREATE TABLE Stations(
	Station INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	StationName VARCHAR(50) NOT NULL DEFAULT 'UNNAMED',
	StationType INT FOREIGN KEY REFERENCES StationTypes(StationType),
	InBuilding INT,
	Activated BIT NOT NULL DEFAULT 1,
	Visible BIT NOT NULL DEFAULT 1,
	
	--Nycklar:

	--Beräknade attribut nedan
	--
	--Referensattribut nedan
	-- STATIONTYPE: references stationtype-table
	-- INBUILDING: references building-table
	    CONSTRAINT FK_Stations_Buildings FOREIGN KEY (InBuilding)
    		REFERENCES Buildings(Building)
    		ON DELETE CASCADE
    		ON UPDATE CASCADE,
	--Extra Begränsningar nedan
	--
	);
CREATE TABLE Employees(
	Employee INT IDENTITY(1,1) PRIMARY KEY NOT NULL,

	Username VARCHAR(20) NOT NULL,
	Password VARCHAR(20) NOT NULL DEFAULT ROUND(RAND() * 1000000000000000000, 0), 
	
	LoggedIn bit NOT NULL DEFAULT 0, 
	Activated BIT NOT NULL DEFAULT 1,
	Visible BIT NOT NULL DEFAULT 1,
	AssignedToStation INT FOREIGN KEY REFERENCES Stations(Station)
	--Nycklar:

	--Beräknade attribut nedan
	--
	-- Referensattribut nedan
	-- Extra Begränsningar nedan
		--#Todo
			-- Check ( 
			-- 		((LoggedIn =1 AND AssignedToStation IS NOT Null ) OR 
			-- 		(LoggedIn =0 AND AssignedToStation IS Null) )
			-- 		AND
			-- 			-- Bara tillåtna kombinationer av Loggedin, Activated och assigned till station ska anges här
			-- 		--(Man får ej vara Icke-Activated och inloggad) (hur skriva dettA?)
			-- 	  )
	--
	);
CREATE TABLE EmployeeTypes(
	EmployeeType INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	EmployeeTypeName VARCHAR(50) NOT NULL DEFAULT 'UNNAMED',

	Activated BIT NOT NULL DEFAULT 1,
	Visible BIT NOT NULL DEFAULT 1,
	
	--Nycklar:

	--Beräknade attribut nedan
	--
	-- Referensattribut nedan
	-- Extra Begränsningar nedan
	--
	);
-- CREATE TABLE EmployeesAreWorkingInStation
	-- (

	-- 	Employee INT NOT NULL FOREIGN KEY Employees(Employee),
	-- 	Station INT NOT NULL FOREIGN KEY Employees(Employee),

		
	-- 	--Nycklar:

	-- 	--Beräknade attribut nedan
	-- 	--
	-- 	-- Referensattribut nedan
	-- 	-- Extra Begränsningar nedan
	-- 	--
	-- )
CREATE TABLE Orders(
	OrderId INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	--Betald bit NOT NULL DEFAULT 0,
	--Avbruten bit NOT NULL DEFAULT 0,
	ByTerminal INT NOT NULL FOREIGN KEY REFERENCES Terminals(Terminal),

	Activated BIT NOT NULL DEFAULT 1, --I princip alltid 1
	Visible BIT NOT NULL DEFAULT 1,  -- I princip alltid 1

	Paid bit NOT NULL DEFAULT 0,
	Canceled bit NOT NULL DEFAULT 0,
	PickedUp bit NOT NULL DEFAULT 0,
	ShowOnScreen bit NOT NULL DEFAULT 1,
	Paused bit NOT NULL DEFAULT 0,
	HappyCustomer bit NOT NULL DEFAULT 1,
	Returned bit NOT NULL DEFAULT 0,
	HasSpit bit NOT NULL DEFAULT 0,
	DeliveredByCompany bit NOT NULL DEFAULT 0, 
	

	--Beräknade attribut nedan
		-- Status PERCENT,  - Beräknas genom ProduktOrder. % på antal färdiga produktordrar kopplade till denna order
		-- PriceTotal - Beräknas med hjälp av View som joinas in i tabellen
	-- Referensattribut nedan:		
		-- CONSTRAINT FK_QueueOrder FOREIGN KEY (QueueNr) REFERENCES QueueNumbers(QueueNumber) -- MÖJLIGT VIS SKRÄP #TODO
	
	-- Extra Begränsningar nedan
		--Validerar
		CONSTRAINT CHK_ORDERS_OrderValidering   
	    	CHECK 
	    		(
					(PickedUp 	=0 or (Paid=1 AND Canceled =0 AND Paused=0 AND Returned=0))
					AND
					(Paid 		=0 or (Canceled=0) )
					AND
					(Canceled 	=0 OR (PickedUp=0 AND Paused =0 AND Returned=0) )
					AND
					(Paused 	=0 OR (PickedUp=0 AND Returned=0 AND Canceled=0 AND Paid=1) )
					AND
					(Returned 	=0 OR (PickedUp=0) )
									
				)
	);
CREATE TABLE EmployeesAreEmployeeTypes(
	--Reference INT IDENTITY(1,1) NOT NULL,  -- N-N samband har "Reference" som kolumnheader istället för "Id"
	Employee INT NOT NULL FOREIGN KEY REFERENCES Employees(Employee),
	EmployeeType INT NOT NULL FOREIGN KEY REFERENCES EmployeeTypes(EmployeeType) ,

	--Nycklar
	PRIMARY KEY (Employee, EmployeeType)
	--Beräknade attribut nedan
	--
	-- Referensattribut nedan
	-- Extra Begränsningar nedan
	--
	);
CREATE TABLE EmployeeTypeCanWorkInStationType(
	--Glöm inte bort att ha använda assert i källtabellen
	--Id INT NOT NULL IDENTIFIER(1,1) , 			--Onödigt skrot men standard att ha id.
	EmployeeType INT NOT NULL FOREIGN KEY REFERENCES EmployeeTypes(EmployeeType),
	StationType INT FOREIGN KEY REFERENCES StationTypes(StationType)


	--Nycklar
	PRIMARY KEY (EmployeeType,StationType)

	--Beräknade attribut nedan
	--
	-- Referensattribut nedan
	-- Extra Begränsningar nedan
	--
	);
CREATE TABLE ProductTypes(
	ProductType INT IDENTITY(1,1) PRIMARY KEY NOT NULL, 
	ProductTypeName VARCHAR(50) NOT NULL DEFAULT 'UNNAMED',
	Activated BIT NOT NULL DEFAULT 1,
	Visible BIT NOT NULL DEFAULT 1,

	
	--Nycklar:

	--Beräknade attribut nedan
	--
	-- Referensattribut nedan
	-- Extra Begränsningar nedan
	--
	);
CREATE TABLE Products(
	Product INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	ProductType INT NOT NULL,

	ProductName VARCHAR(50) NOT NULL DEFAULT 'UNNAMED', 
	Description varchar(500) DEFAULT 'No Description',
	Tillagningstid INT NOT NULL DEFAULT 500,  -- I sekunder
	BasPrice INT NOT NULL DEFAULT 100,
	Activated BIT NOT NULL DEFAULT 1,
	Visible BIT NOT NULL DEFAULT 1,

	--Nycklar
	--Beräknade attribut nedan
	--AckumuleratPrice INT NOT NULL,
	
	-- Referensattribut nedan
	CONSTRAINT FK_Products_ProductTypes FOREIGN KEY (ProductType) 
		REFERENCES ProductTypes(ProductType),
	-- Extra Begränsningar nedan
	CONSTRAINT  UC_Products_NameTypeCombo UNIQUE (ProductName,ProductType) --"Högst en unnamed per type."

	--
	);
CREATE TABLE TypeIsMadeInStationType(    -- Kommentar: type Pizza tillverkas ej i Glassbar
	--Glöm inte att använda Assert i andra tabeller nu.
	-- Reference INT IDENTITY(1,1) PRIMARY KEY NOT NULL ,

	ProductType INT NOT NULL FOREIGN KEY REFERENCES ProductTypes(ProductType),
	StationType INT FOREIGN KEY REFERENCES StationTypes(StationType),
	--Nycklar
	PRIMARY KEY (ProductType,StationType)
	--Beräknade attribut nedan
	--
	-- Referensattribut nedan
	-- Extra Begränsningar nedan
	--
	);
CREATE TABLE Ingredients(
	Ingredient INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	IngredientName VARCHAR(50) NOT NULL DEFAULT 'UNNAMED',
	
	Price INT NOT NULL DEFAULT 5, 
	Activated BIT NOT NULL DEFAULT 1,
	Visible BIT NOT NULL DEFAULT 1,

	
	-- Nycklar :

	--Beräknade attribut nedan
	--
	-- Referensattribut nedan
	-- Extra Begränsningar nedan
	--
	);
CREATE TABLE OrderWasTreatedByEmployeeAtStation(
	--Fungerar som en logger för närvarande. Kommer senare integreras eller rensas bort för integritet. #TODO
	
	Treatment INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	Employee INT FOREIGN KEY REFERENCES Employees(Employee),
	Station Int FOREIGN KEY REFERENCES Stations(Station),
	OrderId INT FOREIGN KEY REFERENCES Orders(OrderId),

	TreatmentTime DateTime,
	
	
	Activated BIT NOT NULL DEFAULT 1,
	Visible BIT NOT NULL DEFAULT 1,

	
	--Nycklar:

	--Beräknade attribut nedan
	--
	-- Referensattribut nedan
	-- Extra Begränsningar nedan
	--
	);
CREATE TABLE ProductOrders
	(
	ProductOrder INT IDENTITY(1,1) NOT NULL,
	Product Int NOT NULL, 											--FK
	OrderId INT NOT NULL, 											--FK
	LockedByStation Int, --FOREIGN KEY REFERENCES Stations(Station),   --FK
	
	Behandlad BIT DEFAULT 1, 

	Activated BIT NOT NULL DEFAULT 1,
	Visible BIT NOT NULL DEFAULT 1,
	Betald BIT NOT NULL DEFAULT 1,
	
	--Nycklar
		primary key (ProductOrder, Product),
	--Beräknade attribut nedan
	-- ProductType Int -- joinas fram med ProductType tabellen för att ge ytterliggare en kolonn. Fås med view.
	-- Specialisering Int --Joinas fram. Visar om den har annorlunda ingredienser än vad Produkt brukar ha.

	-- Referensattribut nedan
    	CONSTRAINT FK_ProductOrders_Product FOREIGN KEY (Product)
    		REFERENCES Products(Product),

    	CONSTRAINT FK_ProdctOrders_Orders FOREIGN KEY (OrderId)
    		REFERENCES Orders(OrderId),

    	CONSTRAINT FK_ProductOrders_Station FOREIGN KEY (LockedByStation)
    		REFERENCES Stations(Station),

	-- Extra Begränsningar nedan
		--An order can be locked by one station at the time.
		--CONSTRAINT UC_ProductOrders_LockedByStation UNIQUE(LockedByStation),
		CONSTRAINT UC_ProductOrders_ID UNIQUE(ProductOrder)
	--
	);
CREATE UNIQUE INDEX  UC_ProductOrders_LockedByStation ON ProductOrders(LockedByStation) WHERE LockedByStation IS NOT NULL;
-- EXTREMT SANNOLIKT ONÖDIG. - FIXA PRODUCTORDER-Tabellen istället, ty ProductOrder (N-1) Product	
-- CREATE TABLE ProductOrdersHaveProducts 
	-- 	(
	-- 	ProductOrder INT NOT NULL FOREIGN KEY REFERENCES ProductOrders(ProductOrder),
	-- 	Product INT NOT NULL FOREIGN KEY REFERENCES Products(Product)



	-- 	--Nycklar:

	-- 		CONSTRAINT PK_Person PRIMARY KEY (ProductOrder,Product); 
	-- 	--Beräknade attribut nedan
	-- 	--
	-- 	-- Referensattribut nedan
	-- 	-- Extra Begränsningar nedan
	-- 	--
	-- 	);

CREATE TABLE Stuffings(
	Lump INT NOT NULL IDENTITY(1,1) PRIMARY KEY, -- Dvs , id, dvs objektet "en klump av ingredienser"

	ProductOrder INT NOT NULL,
	Ingredient INT FOREIGN KEY REFERENCES Ingredients(Ingredient),
	Antal INT NOT NULL,  						--Checka att den är >1 #TODO

	--Nycklar:
		CONSTRAINT FK_Stuffings_ProductOrder FOREIGN KEY (ProductOrder)
			REFERENCES ProductOrders(ProductOrder) 
			ON DELETE CASCADE, --weak entity är ON DELETE CASCADE
	
	--Beräknade attribut nedan
	-- ProductType 									-- Ska fås direkt från (Produkten i) produktordern.
	-- Locked BIT,				--Blir låst när Dens Order är låst (aggregat)

	-- Referensattribut nedan
	-- Extra Begränsningar nedan
	CONSTRAINT UC_POIngredient UNIQUE(ProductOrder,Ingredient)
	--
	);
CREATE TABLE EmployeesHaveProductOrdersLockedInStations(
	--Id INT IDENTIFIER(1,1) NOT NULL, 			--Onödigt skrot men standard att ha id.
	Employee INT NOT NULL FOREIGN KEY REFERENCES Employees(Employee),
	ProductOrder INT NOT NULL FOREIGN KEY REFERENCES ProductOrders(ProductOrder),
	Station INT NOT NULL FOREIGN KEY REFERENCES Stations(Station),

	
	--Nycklar
	PRIMARY KEY (Employee, ProductOrder,Station),
	--Beräknade attribut nedan
	--
	-- Referensattribut nedan
	-- Extra Begränsningar nedan
	--
	);
CREATE TABLE TypeCanHaveIngredients(
	ApprovedIngredient INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	ProductType INT NOT NULL FOREIGN KEY REFERENCES ProductTypes(ProductType),
	Ingredient INT NOT NULL FOREIGN KEY REFERENCES Ingredients(Ingredient),
	IsDemanded BIT NOT NULL DEFAULT 0,
	MaxUnits INT NOT NULL DEFAULT 3, 

	--Nycklar:
	--Beräknade attribut nedan
	--
	-- Referensattribut nedan
	-- Extra Begränsningar nedan
		CONSTRAINT UC_TypeCanHaveIngredients UNIQUE (ProductType,Ingredient), --Kandidatnyckel

	--
	);
--Ej normaliserat 3e nivån. Produkttypen behölls här för att bevara min sanity. (Ty Nyckeln i TypeCanHaveIngredient är delmängd i nyckel för TypeRestriction.)
CREATE TABLE TypeRestrictions(   --Kommentar: OtillåtnaBladningar

	Restriction INT NOT NULL IDENTITY(1,1) PRIMARY KEY,

	ProductType INT NOT NULL,
	ApprovedIngredient INT NOT NULL,
	CannotMixwith INT NOT NULL,

	--Nycklar:
		--
	--Beräknade attribut nedan
		--
	-- Referensattribut nedan

		---denna entitetstyp är weak entity
	    CONSTRAINT FK_TypeRestrictions_ApprovedIngredient FOREIGN KEY (ApprovedIngredient)
    		REFERENCES TypeCanHaveIngredients(ApprovedIngredient)
    		ON DELETE CASCADE
    		ON UPDATE CASCADE,

   		CONSTRAINT FK_TypeRestrictions_CannotMixwithIngredient FOREIGN KEY (CannotMixwith)
    		REFERENCES TypeCanHaveIngredients(ApprovedIngredient),

   		CONSTRAINT FK_TypeRestrictions_ProductType FOREIGN KEY (ProductType)
    		REFERENCES ProductTypes(ProductType)
    		ON DELETE CASCADE
    		ON UPDATE CASCADE,
	
	-- Extra Begränsningar nedan
		CONSTRAINT UC_TypeINGTypeRestriction_Ingredient UNIQUE (ProductType,ApprovedIngredient,CannotMixwith), --Kandidatnyckel
		--CONSTRAINT UC_TypeINGTypeRestriction_Ingredient21 UNIQUE (ProductType,Ingredient2,Ingredient1) --kommutativ Kandidatnyckel? Funkar detta?
	
	--CONSTRAINT UC_Approval (Approval) --Osäkert

	-- BEHÖVS EN CONSTRAINT FÖR ATT KOLLA KOMMUTATIVITET mellan I1 och I2 ! TODO
	--
	);
--Dessa två nedan är buggiga
CREATE TABLE ProductHaveIngredients(
	Reference INT NOT NULL IDENTITY(1,1) PRIMARY KEY,

	Product INT NOT NULL FOREIGN KEY REFERENCES Products(Product),
	Ingredient INT FOREIGN KEY REFERENCES Ingredients(Ingredient),
	
	-- Nycklar:

	--Beräknade attribut nedan
	--
	-- Referensattribut nedan
	-- Extra Begränsningar nedan
	CONSTRAINT UC_OnePair_HAVEINGREDIENT UNIQUE (Product,Ingredient)

	-- -- SKA BEGRÄNSAS AV VILKA ingredienser den FÅR ha från ProductCanHave. Hur fixa detta? TODO
	-- 	CHECK ( Kolla ifall Ingredient finns i ProductCanHaveIngredients, ANNARS REJECT (dvs kolla ifall != ) )
	--
	);
CREATE TABLE ProductCanHaveIngredients(
	Reference INT NOT NULL IDENTITY(1,1) PRIMARY KEY,

	Product INT NOT NULL FOREIGN KEY REFERENCES Products(Product),
	Ingredient INT FOREIGN KEY REFERENCES Ingredients(Ingredient),	
	
	--Nycklar:
	--Beräknade attribut nedan
	--
	-- Referensattribut nedan
	-- Extra Begränsningar nedan
		CONSTRAINT UC_OnePair_CANHAVEINCREDIENT UNIQUE (Product,Ingredient)

	-- CHECK ( Finns Ingredient med i TypeCanHaveIngredient?
	-- 		)

	-- CHECK (Finns (Ingredient,X) med i TypeRestrictions? ISF REJECTA (dvs checka att != gäller ) )
	-- 		      -------------
	-- 		      Är tupler av alla möjliga kombinationer mellan Ingredient och övriga ingredients för denna Produkt)
	-- SKA BEGRÄNSAS AV VILKA ingredienser den FÅR ha från TypeRestriction. Hur fixa detta? TODO
	--
	);

------------------------------------------------------------------------
CREATE TABLE Choices(  --Hierarkisk struktur , Ger förhoppningsvis "menyträd"
	Id INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	--IsParentTo INT FOREIGN KEY REFERENCES Choices(id),
	IsSubTo INT FOREIGN KEY REFERENCES Choices(id),
	StringRep VARCHAR(100) DEFAULT 'UNNAMED-CHOICE',
	Description VARCHAR(500) DEFAULT NULL,
	
	--Beräknade attribut nedan
	--
	-- Referensattribut nedan
	-- Extra Begränsningar nedan

		--CONSTRAINT  UC_edge UNIQUE (IsSubTo)

	--
	);
CREATE TABLE PossibleCommandsInStationType( -- Bygger upp Choices med funktionalitet. Kopplar en Stored procedure/funktion till en choice (om det behövs)  

	MethodSignature INT IDENTITY(1,1) NOT NULL, -- ID

	StationType INT FOREIGN KEY REFERENCES StationTypes(StationType),
	Choice INT FOREIGN KEY REFERENCES Choices(Id),	
	ConnectedProcedure INT DEFAULT NULL, --blir en gÖR DEFAULT till 1, Stored Procedures ska länkas från en tabell.
	--Nycklar
		PRIMARY KEY (Choice,StationType)
		--
	--Beräknade attribut nedan
	--
	-- Referensattribut nedan
	-- Extra Begränsningar nedan
	--
	);

------------------------------------------------------------------------
--------------------- HÅRDKODAT ----------------------------------------
------------FÖRSLAG TILL VIEWS, PROCEDURES OCH TRIGGERS-----------------


	--VIEWS - KOMIHÅG EXISTS, ALL (tuplekalkylens Existenskvantifikator)

	-- View för att se alla Orders - inklusive några beräknade kolonner
	-- View för att se alla 100 senaste ordrar.

	-- View för att "se alla rader i PRODUKTordrar" för en viss Order
	-- View för att se stuffings för en särskilt PRODUKTordrer
	-- View för att se alla PRODUKTordrar som är "Behandlade"
	-- View för att se alla PRODUKTordrar where "Låstavstation = null"


	-- View för att se alla Produkter för en viss produkttyp
	-- View för att se alla Employees av en viss type
	-- View för att se Stuffings i en särskild Produkt

	-- View för att se alla ingredienser som är tillåtna för en särskild produkt"
	-- View för att se alla ingredienser som är tillåtna för en särskild produkttyp"
	-- View för att se alla ingredienser som en produkt HAR"


	-- View Över alla byggnader
	-- View för att see alla stations i en viss Building
	-- View för att se alla stations för en viss stationtype
	-- View för att se alla customers i en viss building
	-- View för att se alla ordrar [PÅGÅENDE | FÄRDIGA] (och betalda) för infoscreen/köscreen
	-- En-Rads-VIew för att se Kvitto för en särskild order, med all viktig kvittoinfo.

	-- View för att se "ProduktOrder med Stuffingsklump" för särskild Station enligt Stationtypens krav.

	-- View över alla employees som jobbar i särskild station S
	-- View över alla employees som är inloggade
	-- View över alla Activatede/AvActivatede stationer

	-- Choices views
	-- View över en "Subs" för särskild "menynod".
	-- View över "Parents" för särskild "menynod"
------------------------------------------------------------------------
--Procedure

	--Procedures för att läggatill (eller tabort) whatever.. (en procedure för varje entitetstyp)
	-- Kan bli hur många som helst här...

	-------------ORDER PROCEDURES
	-- Procedure för att Skapa en ny tom order
	-- Procedure för att lägga in en produkt i en order.
	-- Procedure för att Ta bort ingrediens i en produktorder
	-- Procedure för att Lägga till Ingrediens i en produktorder.
	-- Procedure för att skapa en ny ..etc etc

	--många av dessa behövs inte då DATAGRID i winform kan användas istället, och uppdatera hela tabeller.

	------------ Management procedures
	-- För att lägga till användare (+en procedure för att ta bort)
	-- För att lägga till building
	-- För att lägga till station
	-- För att lägga till stationtype
	-- För att lägga till terminal
	-- För att lägga till produktype
	-- För att lägga till ingrediens
	--Kanske blir smartare med att bara använda DATAGRIDS på ett smart sätt. 
	------------------------------------------------------------------------

	-- Funktioner som räknar ut saker
	--Funktion som räknar ut värdet av alla betalda ordrar

------------------------------------------------------------------------
--Triggers
	-- Triggers Som kollar ifall Ingredient par redan finns Otillåtna blandningar
	-- Trigger som kollar ifall Employee Får jobba i station
	--etc

------------------------------------------------------------------------
--------------------------Alla INSERTS nedan ---------------------------
--Initials
	GO

	SET IDENTITY_INSERT Buildings ON
		INSERT INTO Buildings (Building, BuildingNAme) VALUES (1,'TonysMainPizzaHouse');
		INSERT INTO Buildings (Building, BuildingNAme,Activated) VALUES (2,'Tonys UnderGroundPizza',0);
	SET IDENTITY_INSERT Buildings OFF
	GO

	INSERT INTO Terminals(Building) VALUES (1);
	INSERT INTO Terminals(Building) VALUES (1);
	INSERT INTO Terminals(Building) VALUES (1);
	INSERT INTO InfoScreens(Building) VALUES (1);
	Go
------------------------------------------------------------------------
--Stationtypes
	SET IDENTITY_INSERT StationTypes ON
		INSERT INTO StationTypes (StationType, StationTypeName) VALUES (1,'Salladsbar');
		INSERT INTO StationTypes (StationType, StationTypeName) VALUES (2,'BigPizzaStation');
		INSERT INTO StationTypes (StationType, StationTypeName) VALUES (3,'IceCreamBar');
		INSERT INTO StationTypes (StationType, StationTypeName) VALUES (4,'Cashier');
		INSERT INTO StationTypes (StationType, StationTypeName) VALUES (5,'Office');
	SET IDENTITY_INSERT StationTypes OFF

	GO
--Stations
		INSERT INTO Stations (StationType, StationName, InBuilding) VALUES (1,'Mini SaladBar',1);
		INSERT INTO Stations (StationType, StationName, InBuilding) VALUES (2,'Corner PizzaStation',1);
		INSERT INTO Stations (StationType, StationName, InBuilding) VALUES (3,'Quick IceCreamBar',1);
		INSERT INTO Stations (StationType, StationName, InBuilding) VALUES (4,'Cashier 1',1);
		INSERT INTO Stations (StationType, StationName, InBuilding) VALUES (4,'Cashier 2',1);
		INSERT INTO Stations (StationType, StationName, InBuilding) VALUES (4,'Cashier 3',1);
		INSERT INTO Stations (StationType, StationName, InBuilding) VALUES (5,'First Office',1);
--EmployeeTypes
	SET IDENTITY_INSERT EmployeeTypes ON
		INSERT INTO EmployeeTypes (EmployeeType, EmployeeTypeName) VALUES (1,'Utbildad SuperKock');
		INSERT INTO EmployeeTypes (EmployeeType, EmployeeTypeName) VALUES (2,'Pizzabaker');
		INSERT INTO EmployeeTypes (EmployeeType, EmployeeTypeName) VALUES (3,'Cashier');
		INSERT INTO EmployeeTypes (EmployeeType, EmployeeTypeName) VALUES (4,'Administrator');
		INSERT INTO EmployeeTypes (EmployeeType, EmployeeTypeName) VALUES (5,'Incompetent');
	SET IDENTITY_INSERT EmployeeTypes OFF
	GO

	GO
--EType-2-StatType
	INSERT INTO EmployeeTypeCanWorkInStationType (EmployeeType, StationType) VALUES (1,1);
	INSERT INTO EmployeeTypeCanWorkInStationType (EmployeeType, StationType) VALUES (1,2);
	INSERT INTO EmployeeTypeCanWorkInStationType (EmployeeType, StationType) VALUES (1,3);
	INSERT INTO EmployeeTypeCanWorkInStationType (EmployeeType, StationType) VALUES (1,4);
	INSERT INTO EmployeeTypeCanWorkInStationType (EmployeeType, StationType) VALUES (2,2);
	INSERT INTO EmployeeTypeCanWorkInStationType (EmployeeType, StationType) VALUES (3,4);
	INSERT INTO EmployeeTypeCanWorkInStationType (EmployeeType, StationType) VALUES (4,5);
	GO
--Employees	
	SET IDENTITY_INSERT Employees on
		INSERT INTO Employees (Employee,Username) VALUES (1, 'GregAdmin');
		INSERT INTO Employees (Employee,Username) VALUES (2, 'LisaCashier');
		INSERT INTO Employees (Employee,Username) VALUES (3, 'BageyTheBaker');
		INSERT INTO Employees (Employee,Username) VALUES (4, 'IceyTheIceman');
	SET IDENTITY_INSERT Employees OFF

	GO
--Emp-2-EmpType
	INSERT INTO EmployeesAreEmployeeTypes (Employee,EmployeeType) VALUES (1, 4);
	INSERT INTO EmployeesAreEmployeeTypes (Employee,EmployeeType) VALUES (2, 3);
	INSERT INTO EmployeesAreEmployeeTypes (Employee,EmployeeType) VALUES (3, 2);
	INSERT INTO EmployeesAreEmployeeTypes (Employee,EmployeeType) VALUES (4, 1);
	GO
--Producttypes
	SET IDENTITY_INSERT ProductTypes ON
		INSERT INTO ProductTypes (ProductType, ProductTypeName) VALUES (1,'Pizza');
		INSERT INTO ProductTypes (ProductType, ProductTypeName) VALUES (2,'Sallad');
		INSERT INTO ProductTypes (ProductType, ProductTypeName) VALUES (3,'IceCream');
		INSERT INTO ProductTypes (ProductType, ProductTypeName) VALUES (4,'Fresh Juice');
		INSERT INTO ProductTypes (ProductType, ProductTypeName) VALUES (5,'Drinks');
		INSERT INTO ProductTypes (ProductType, ProductTypeName) VALUES (6,'Extras');
	SET IDENTITY_INSERT ProductTypes OFF

	GO
--Products
	INSERT INTO Products(ProductType, ProductName) VALUES (1,'Vesuvio'); --1
	INSERT INTO Products(ProductType, ProductName) VALUES (1,'KebabPizza'); --2
	INSERT INTO Products(ProductType, ProductName) VALUES (1,'Capricosa');--3
	INSERT INTO Products(ProductType, ProductName) VALUES (1,'Mexicana');--4
	INSERT INTO Products(ProductType, ProductName) VALUES (2,'ChickenSalad');--5
	INSERT INTO Products(ProductType, ProductName) VALUES (2,'CeasarSalad'); --6
	INSERT INTO Products(ProductType, ProductName) VALUES (1,'Bolognese');--7
	INSERT INTO Products(ProductType, ProductName) VALUES (1,'Calzone');--8
	INSERT INTO Products(ProductType, ProductName) VALUES (1,'Hawaii');--9
	INSERT INTO Products(ProductType, ProductName) VALUES (1,'QuattroFormaggio');--10
	INSERT INTO Products(ProductType, ProductName) VALUES (1,'Marinara');--11
	INSERT INTO Products(ProductType, ProductName) VALUES (2,'FetaSalad');--12
	INSERT INTO Products(ProductType, ProductName) VALUES (5,'CocaCola');--13
	INSERT INTO Products(ProductType, ProductName) VALUES (5,'Sprite');--14
	INSERT INTO Products(ProductType, ProductName) VALUES (5,'Fanta');--15
	INSERT INTO Products(ProductType, ProductName) VALUES (5,'Red Bull');--16
	INSERT INTO Products(ProductType, ProductName) VALUES (6,'PommesFrites');--17
	INSERT INTO Products(ProductType, ProductName) VALUES (6,'FriedChicken');--18
	INSERT INTO Products(ProductType, ProductName) VALUES (3,'Magnum Almond'); --19
	INSERT INTO Products(ProductType, ProductName) VALUES (3,'Sandwich'); --20
	INSERT INTO Products(ProductType, ProductName) VALUES (3,'Solero'); --21
	INSERT INTO Products(ProductType, ProductName) VALUES (3,'Twister'); --22
	INSERT INTO Products(ProductType, ProductName) VALUES (3,'Igloo'); --23
	INSERT INTO Products(ProductType, ProductName) VALUES (4,'OrangeJuice'); --24
	INSERT INTO Products(ProductType, ProductName) VALUES (4,'AppleJuice'); --25
	INSERT INTO Products(ProductType, ProductName) VALUES (4,'GamerJuice'); --26
	INSERT INTO Products(ProductType, ProductName,Activated) VALUES (5,'CocaCola Strawberrytaste',0);--27

	GO
--PType-2-StatType
	INSERT INTO TypeIsMadeInStationType(ProductType, StationType) VALUES (1,2);
	INSERT INTO TypeIsMadeInStationType(ProductType, StationType) VALUES (2,1);
	INSERT INTO TypeIsMadeInStationType(ProductType, StationType) VALUES (3,3);
	INSERT INTO TypeIsMadeInStationType(ProductType, StationType) VALUES (4,3);
	INSERT INTO TypeIsMadeInStationType(ProductType, StationT ype) VALUES (5,5);
	INSERT INTO TypeIsMadeInStationType(ProductType, StationType) VALUES (6,5);
--Ingredienser
	SET IDENTITY_INSERT Ingredients ON
		
		INSERT INTO Ingredients(Ingredient,IngredientName) VALUES (1,'Salami');
		INSERT INTO Ingredients(Ingredient,IngredientName) VALUES (2,'Kebabkött');
		INSERT INTO Ingredients(Ingredient,IngredientName) VALUES (3,'Cheddar');
		INSERT INTO Ingredients(Ingredient,IngredientName) VALUES (4,'Mozarella');
		INSERT INTO Ingredients(Ingredient,IngredientName) VALUES (5,'Fefferoni');
		INSERT INTO Ingredients(Ingredient,IngredientName) VALUES (6,'Gräddost');
		INSERT INTO Ingredients(Ingredient,IngredientName) VALUES (7,'Amerikansk Deg');
		INSERT INTO Ingredients(Ingredient,IngredientName) VALUES (8,'Italiensk Deg');
		INSERT INTO Ingredients(Ingredient,IngredientName) VALUES (9,'Extra Snabb Tillagning');
		INSERT INTO Ingredients(Ingredient,IngredientName) VALUES (10,'Kycklingfilé');
		INSERT INTO Ingredients(Ingredient,IngredientName) VALUES (11,'Ostkub');
		INSERT INTO Ingredients(Ingredient,IngredientName) VALUES (12,'KoktPasta');
		INSERT INTO Ingredients(Ingredient,IngredientName) VALUES (13,'Bulgur');
		INSERT INTO Ingredients(Ingredient,IngredientName) VALUES (14,'Snuspåse');
		INSERT INTO Ingredients(Ingredient,IngredientName) VALUES (15,'Oliver');
		INSERT INTO Ingredients(Ingredient,IngredientName) VALUES (16,'Ananas');
		INSERT INTO Ingredients(Ingredient,IngredientName) VALUES (17,'Tonfisk');
		INSERT INTO Ingredients(Ingredient,IngredientName) VALUES (18,'Gul Lök');
		INSERT INTO Ingredients(Ingredient,IngredientName) VALUES (19,'Championer');
		INSERT INTO Ingredients(Ingredient,IngredientName) VALUES (20,'Tomatsås');
		INSERT INTO Ingredients(Ingredient,IngredientName) VALUES (21,'Skinka');
		INSERT INTO Ingredients(Ingredient,IngredientName) VALUES (22,'Ruccola');
		INSERT INTO Ingredients(Ingredient,IngredientName) VALUES (23,'Tacosås');
		INSERT INTO Ingredients(Ingredient,IngredientName) VALUES (24,'Gräddfil');
		INSERT INTO Ingredients(Ingredient,IngredientName) VALUES (25,'Avocado');
		INSERT INTO Ingredients(Ingredient,IngredientName) VALUES (26,'Paprika');
		INSERT INTO Ingredients(Ingredient,IngredientName) VALUES (27,'Köttfärs');
		INSERT INTO Ingredients(Ingredient,IngredientName) VALUES (28,'Chilisås');
		INSERT INTO Ingredients(Ingredient,IngredientName) VALUES (29,'Isbergssallad');
		INSERT INTO Ingredients(Ingredient,IngredientName) VALUES (30,'Röd Lök');
		INSERT INTO Ingredients(Ingredient,IngredientName) VALUES (31,'Rhode Island dressing');
		INSERT INTO Ingredients(Ingredient,IngredientName) VALUES (32,'Vinägrett');
		INSERT INTO Ingredients(Ingredient,IngredientName) VALUES (33,'Vitlöksdressing');
		INSERT INTO Ingredients(Ingredient,IngredientName) VALUES (34,'Vitlökssås');
		INSERT INTO Ingredients(Ingredient,IngredientName) VALUES (35,'Bearnaise');
		INSERT INTO Ingredients(Ingredient,IngredientName) VALUES (36,'Vitlök');
		INSERT INTO Ingredients(Ingredient,IngredientName) VALUES (37,'Persilja');
		INSERT INTO Ingredients(Ingredient,IngredientName) VALUES (38,'Ceasardressing');
		INSERT INTO Ingredients(Ingredient,IngredientName) VALUES (39,'Räkor');
		INSERT INTO Ingredients(Ingredient,IngredientName) VALUES (40,'Ägg');
		INSERT INTO Ingredients(Ingredient,IngredientName) VALUES (41,'Spenat');
		INSERT INTO Ingredients(Ingredient,IngredientName) VALUES (42,'Kronärtskocka');
		INSERT INTO Ingredients(Ingredient,IngredientName) VALUES (43,'Fetaost');
		INSERT INTO Ingredients(Ingredient,IngredientName) VALUES (44,'Musslor');
		INSERT INTO Ingredients(Ingredient,IngredientName) VALUES (45,'Bacon');
		INSERT INTO Ingredients(Ingredient,IngredientName) VALUES (46,'Parmaskinka');
		INSERT INTO Ingredients(Ingredient,IngredientName) VALUES (47,'Parmesanost');
		INSERT INTO Ingredients(Ingredient,IngredientName) VALUES (48,'Gurka');
		INSERT INTO Ingredients(Ingredient,IngredientName) VALUES (49,'Färska Tomater');
		INSERT INTO Ingredients(Ingredient,IngredientName) VALUES (50,'Grön Chili');
		INSERT INTO Ingredients(Ingredient,IngredientName) VALUES (51,'TacoMix');




	SET IDENTITY_INSERT Ingredients OFF
	GO
--Pizza pålägg TILLÅTNA
	INSERT INTO TypeCanHaveIngredients(ProductType, Ingredient) VALUES (1,1);
	INSERT INTO TypeCanHaveIngredients(ProductType, Ingredient) VALUES (1,2);
	INSERT INTO TypeCanHaveIngredients(ProductType, Ingredient) VALUES (1,3);
	INSERT INTO TypeCanHaveIngredients(ProductType, Ingredient) VALUES (1,4);
	INSERT INTO TypeCanHaveIngredients(ProductType, Ingredient) VALUES (1,5);
	INSERT INTO TypeCanHaveIngredients(ProductType, Ingredient) VALUES (1,6);
	INSERT INTO TypeCanHaveIngredients(ProductType, Ingredient) VALUES (1,7);
	INSERT INTO TypeCanHaveIngredients(ProductType, Ingredient) VALUES (1,8);
	INSERT INTO TypeCanHaveIngredients(ProductType, Ingredient) VALUES (1,9);
	INSERT INTO TypeCanHaveIngredients(ProductType, Ingredient) VALUES (1,15);
	INSERT INTO TypeCanHaveIngredients(ProductType, Ingredient) VALUES (1,16);
	INSERT INTO TypeCanHaveIngredients(ProductType, Ingredient) VALUES (1,17);
	INSERT INTO TypeCanHaveIngredients(ProductType, Ingredient) VALUES (1,18);
	INSERT INTO TypeCanHaveIngredients(ProductType, Ingredient) VALUES (1,19);
	INSERT INTO TypeCanHaveIngredients(ProductType, Ingredient) VALUES (1,20);
	INSERT INTO TypeCanHaveIngredients(ProductType, Ingredient) VALUES (1,21);
	INSERT INTO TypeCanHaveIngredients(ProductType, Ingredient) VALUES (1,22);
	INSERT INTO TypeCanHaveIngredients(ProductType, Ingredient) VALUES (1,23);
	INSERT INTO TypeCanHaveIngredients(ProductType, Ingredient) VALUES (1,24);
	INSERT INTO TypeCanHaveIngredients(ProductType, Ingredient) VALUES (1,25);
	INSERT INTO TypeCanHaveIngredients(ProductType, Ingredient) VALUES (1,26);
	INSERT INTO TypeCanHaveIngredients(ProductType, Ingredient) VALUES (1,27);
	INSERT INTO TypeCanHaveIngredients(ProductType, Ingredient) VALUES (1,28);
	INSERT INTO TypeCanHaveIngredients(ProductType, Ingredient) VALUES (1,30);
	INSERT INTO TypeCanHaveIngredients(ProductType, Ingredient) VALUES (1,34);
	INSERT INTO TypeCanHaveIngredients(ProductType, Ingredient) VALUES (1,35);
	INSERT INTO TypeCanHaveIngredients(ProductType, Ingredient) VALUES (1,36);
	INSERT INTO TypeCanHaveIngredients(ProductType, Ingredient) VALUES (1,37);
	INSERT INTO TypeCanHaveIngredients(ProductType, Ingredient) VALUES (1,39);
	INSERT INTO TypeCanHaveIngredients(ProductType, Ingredient) VALUES (1,40);
	INSERT INTO TypeCanHaveIngredients(ProductType, Ingredient) VALUES (1,41);
	INSERT INTO TypeCanHaveIngredients(ProductType, Ingredient) VALUES (1,42);
	INSERT INTO TypeCanHaveIngredients(ProductType, Ingredient) VALUES (1,43);
	INSERT INTO TypeCanHaveIngredients(ProductType, Ingredient) VALUES (1,44);
	INSERT INTO TypeCanHaveIngredients(ProductType, Ingredient) VALUES (1,45);
	INSERT INTO TypeCanHaveIngredients(ProductType, Ingredient) VALUES (1,46);
	INSERT INTO TypeCanHaveIngredients(ProductType, Ingredient) VALUES (1,47);
	INSERT INTO TypeCanHaveIngredients(ProductType, Ingredient) VALUES (1,49);
	INSERT INTO TypeCanHaveIngredients(ProductType, Ingredient) VALUES (1,50);
	INSERT INTO TypeCanHaveIngredients(ProductType, Ingredient) VALUES (1,51);
--SalladPålägg TILLÅTNA
	INSERT INTO TypeCanHaveIngredients(ProductType, Ingredient) VALUES (2,2);
	INSERT INTO TypeCanHaveIngredients(ProductType, Ingredient) VALUES (2,4);
	INSERT INTO TypeCanHaveIngredients(ProductType, Ingredient) VALUES (2,5);
	INSERT INTO TypeCanHaveIngredients(ProductType, Ingredient) VALUES (2,9);
	INSERT INTO TypeCanHaveIngredients(ProductType, Ingredient) VALUES (2,10);
	INSERT INTO TypeCanHaveIngredients(ProductType, Ingredient) VALUES (2,11);
	INSERT INTO TypeCanHaveIngredients(ProductType, Ingredient) VALUES (2,12);
	INSERT INTO TypeCanHaveIngredients(ProductType, Ingredient) VALUES (2,13);
	INSERT INTO TypeCanHaveIngredients(ProductType, Ingredient) VALUES (2,15);
	INSERT INTO TypeCanHaveIngredients(ProductType, Ingredient) VALUES (2,16);
	INSERT INTO TypeCanHaveIngredients(ProductType, Ingredient) VALUES (2,17);
	INSERT INTO TypeCanHaveIngredients(ProductType, Ingredient) VALUES (2,18);
	INSERT INTO TypeCanHaveIngredients(ProductType, Ingredient) VALUES (2,19);
	INSERT INTO TypeCanHaveIngredients(ProductType, Ingredient) VALUES (2,21);
	INSERT INTO TypeCanHaveIngredients(ProductType, Ingredient) VALUES (2,22);
	INSERT INTO TypeCanHaveIngredients(ProductType, Ingredient) VALUES (2,25);
	INSERT INTO TypeCanHaveIngredients(ProductType, Ingredient) VALUES (2,26);
	INSERT INTO TypeCanHaveIngredients(ProductType, Ingredient) VALUES (2,29);
	INSERT INTO TypeCanHaveIngredients(ProductType, Ingredient) VALUES (2,30);
	INSERT INTO TypeCanHaveIngredients(ProductType, Ingredient) VALUES (2,31);
	INSERT INTO TypeCanHaveIngredients(ProductType, Ingredient) VALUES (2,32);
	INSERT INTO TypeCanHaveIngredients(ProductType, Ingredient) VALUES (2,33);
	INSERT INTO TypeCanHaveIngredients(ProductType, Ingredient) VALUES (2,36);
	INSERT INTO TypeCanHaveIngredients(ProductType, Ingredient) VALUES (2,37);
	INSERT INTO TypeCanHaveIngredients(ProductType, Ingredient) VALUES (2,38);
	INSERT INTO TypeCanHaveIngredients(ProductType, Ingredient) VALUES (2,39);
	INSERT INTO TypeCanHaveIngredients(ProductType, Ingredient) VALUES (2,40);
	INSERT INTO TypeCanHaveIngredients(ProductType, Ingredient) VALUES (2,41);
	INSERT INTO TypeCanHaveIngredients(ProductType, Ingredient) VALUES (2,42);
	INSERT INTO TypeCanHaveIngredients(ProductType, Ingredient) VALUES (2,43);
	INSERT INTO TypeCanHaveIngredients(ProductType, Ingredient) VALUES (2,45);
	INSERT INTO TypeCanHaveIngredients(ProductType, Ingredient) VALUES (2,46);
	INSERT INTO TypeCanHaveIngredients(ProductType, Ingredient) VALUES (2,48);
	INSERT INTO TypeCanHaveIngredients(ProductType, Ingredient) VALUES (2,49);

--Ej Tillåtna blandningar på pizzor
	INSERT INTO TypeRestrictions(ProductType, ApprovedIngredient, CannotMixWith) VALUES (1,1,2);  --salami och kebabkött
	INSERT INTO TypeRestrictions(ProductType, ApprovedIngredient, CannotMixWith) VALUES (1,2,17); --kebabkött och tonfisk
	INSERT INTO TypeRestrictions(ProductType, ApprovedIngredient, CannotMixWith) VALUES (1,7,8);  --Amerikanskdeg och Italienskdeg
	INSERT INTO TypeRestrictions(ProductType, ApprovedIngredient, CannotMixWith) VALUES (2,31,32);
	INSERT INTO TypeRestrictions(ProductType, ApprovedIngredient, CannotMixWith) VALUES (2,32,33);
	INSERT INTO TypeRestrictions(ProductType, ApprovedIngredient, CannotMixWith) VALUES (2,38,32);
	INSERT INTO TypeRestrictions(ProductType, ApprovedIngredient, CannotMixWith) VALUES (2,38,33);
	INSERT INTO TypeRestrictions(ProductType, ApprovedIngredient, CannotMixWith) VALUES (2,44,10);
	

--Choices Tree (Kommer kanske komma till nytta någon gång)
	SET IDENTITY_INSERT Choices ON
		INSERT INTO Choices(Id, IsSubTo, StringRep) VALUES (1,null,'root');
		INSERT INTO Choices(Id, IsSubTo, StringRep) VALUES (2,1, 'Login Choices');
		INSERT INTO Choices(Id, IsSubTo, StringRep) VALUES (3,2, 'Login Choices1');
		INSERT INTO Choices(Id, IsSubTo, StringRep) VALUES (4,2, 'Login Choices2');
		INSERT INTO Choices(Id, IsSubTo, StringRep) VALUES (5,2, 'Login Choices3');
		INSERT INTO Choices(Id, IsSubTo, StringRep) VALUES (6,2, 'Login Choices4');


		INSERT INTO Choices(Id, IsSubTo, StringRep) VALUES (7,1, 'CustomerMainChoices');
		

		INSERT INTO Choices(Id, IsSubTo, StringRep) VALUES (8,1, 'CashierChoices');


		INSERT INTO Choices(Id, IsSubTo, StringRep) VALUES (9,1, 'Administrator Choices');
		

		INSERT INTO Choices(Id, IsSubTo, StringRep) VALUES (10,1, 'PizzaBaker MainChoices');
		

		INSERT INTO Choices(Id, IsSubTo, StringRep) VALUES (11,1, 'SalladMaker Choices');
	SET IDENTITY_INSERT Choices OFF



















---------------------------------------------------
---Andres Inserts---
---------Pizza Inserts och relaterade Indata------
--Möjliga ingredienser på Vesuvio
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (1,2);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (1,3);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (1,4);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (1,5);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (1,6);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (1,7);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (1,8);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (1,9);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (1,15);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (1,18);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (1,20);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (1,21);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (1,22);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (1,26);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (1,28);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (1,34);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (1,35);

--Möjliga Ingredienser i KebabPizza 
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (2,2);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (2,5);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (2,6);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (2,7);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (2,8);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (2,9);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (2,15);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (2,16);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (2,18);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (2,19);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (2,20);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (2,21);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (2,22);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (2,23);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (2,24);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (2,25);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (2,26);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (2,28);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (2,29);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (2,30);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (2,34);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (2,35);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (2,36);
--Möjliga ingredienser på Capricosa
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (3,3);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (3,4);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (3,5);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (3,6);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (3,7);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (3,8);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (3,9);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (3,15);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (3,16);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (3,20);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (3,21);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (3,22);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (3,26);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (3,34);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (3,35);
--Möjliga ingredienser på Mexicana
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (4,4);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (4,5);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (4,6);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (4,7);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (4,8);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (4,9);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (4,18);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (4,20);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (4,21);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (4,22);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (4,23);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (4,24);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (4,25);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (4,26);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (4,27);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (4,28);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (4,30);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (4,34);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (4,36);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (4,37);
--Möjliga ingredienser på Marinara
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (11,4);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (11,5);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (11,6);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (11,7);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (11,8);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (11,9);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (11,18);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (11,20);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (11,21);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (11,22);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (11,34);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (11,35);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (11,36);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (11,37);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (11,39);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (11,41);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (11,44);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (11,47);
--Möjliga ingredienser på Hawaii
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (9,3);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (9,4);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (9,5);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (9,6);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (9,7);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (9,8);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (9,9);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (9,20);
--Möjliga ingredienser på Bolognese
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (7,5);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (7,7);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (7,8);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (7,9);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (7,15);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (7,18);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (7,19);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (7,20);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (7,21);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (7,22);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (7,23);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (7,24);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (7,25);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (7,26);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (7,27);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (7,28);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (7,34);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (7,35);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (7,36);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (7,45);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (7,46);
--Möjliga ingredienser på Quattro Formaggio
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (10,1);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (10,2);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (10,3);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (10,4);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (10,5);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (10,6);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (10,7);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (10,8);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (10,9);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (10,15);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (10,19);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (10,20);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (10,21);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (10,22);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (10,23);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (10,27);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (10,28);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (10,34);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (10,35);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (10,45);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (10,46);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (10,47);
--Möjliga ingredienser på Calzone
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (8,6);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (8,8);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (8,9);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (8,19);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (8,20);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (8,21);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (8,28);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (8,34);
	INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (8,35);

------PizzaRecept 
	--Standard Vesuvio
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (1,6);
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (1,8);
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (1,20);
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (1,21);
	--Standard Kebabpizza
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (2,2);
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (2,5);
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (2,8);
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (2,20);
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (2,34);
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (2,49);
	--Standard Capricosa
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (3,6);
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (3,8);
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (3,19);
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (3,20);
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (3,21);
	--Standard Mexicana
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (4,6);
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (4,8);
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (4,18);
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (4,20);
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (4,23);
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (4,27);
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (4,50);
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (4,51);
	--Standard Bolognese
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (7,6);
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (7,8);
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (7,18);
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (7,20);
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (7,27);
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (7,40);
	--Standard Calzone
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (8,4);
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (8,6);
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (8,8);
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (8,20);
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (8,21);
	--Standard Hawaii
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (9,6);
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (9,8);
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (9,16);
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (9,20);
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (9,21);
	--Standard QuattroFormaggio
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (10,3);
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (10,4);
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (10,6);
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (10,8);
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (10,20);
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (10,47);
	--Standard Marinara
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (11,6);
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (11,8);
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (11,20);
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (11,39);
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (11,44);
		


---------Möjliga ingredienser Sallad
	--Möjliga ingredienser på Kycklingsallad
		INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (5,9);
		INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (5,10);
		INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (5,11);
		INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (5,12);
		INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (5,13);
		INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (5,18);
		INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (5,19);
		INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (5,21);
		INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (5,22);
		INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (5,25);
		INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (5,26);
		INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (5,29);
		INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (5,30);
		INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (5,31);
		INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (5,32);
		INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (5,33);
		INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (5,36);
		INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (5,37);
		INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (5,47);
	--Möjliga ingredienser på Ceasarsallad
		INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (6,9);
		INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (6,10);
		INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (6,11);
		INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (6,12);
		INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (6,13);
		INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (6,15);
		INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (6,18);
		INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (6,22);
		INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (6,25);
		INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (6,29);
		INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (6,30);
		INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (6,31);
		INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (6,32);
		INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (6,33);
		INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (6,36);
		INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (6,37);
		INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (6,38);
		INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (6,39);
		INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (6,40);
		INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (6,45);
		INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (6,47);
	--Möjliga ingredienser på FetaostSallad 
		INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (12,4);
		INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (12,5);
		INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (12,9);
		INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (12,10);
		INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (12,12);
		INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (12,13);
		INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (12,15);
		INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (12,17);
		INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (12,18);
		INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (12,21);
		INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (12,22);
		INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (12,25);
		INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (12,29);
		INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (12,30);
		INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (12,31);
		INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (12,32);
		INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (12,33);
		INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (12,39);
		INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (12,40);
		INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (12,41);
		INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (12,42);
		INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (12,43);
		INSERT INTO ProductCanHaveIngredients(Product, Ingredient) VALUES (12,46);
---------SalladRecept
	--Standard Kycklingsallad
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (5,10);
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (5,11);
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (5,12);
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (5,22);
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (5,25);
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (5,29);
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (5,30);
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (5,31);
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (5,45);
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (5,47);
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (5,48);
	--Standard CeasarSallad
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (6,10);
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (6,18);
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (6,29);
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (6,30);
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (6,38);
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (6,45);
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (6,47);
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (6,48);
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (6,49);
	--Standard FetaOstSallad
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (12,13);
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (12,22);
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (12,25);
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (12,26);
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (12,29);
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (12,30);
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (12,31);
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (11,41);
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (11,42);
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (11,43);
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (11,48);
		INSERT INTO ProductHaveIngredients(Product, Ingredient) VALUES (11,49);
--Skapa order
	GO
	declare @TerminalID int;
	declare @OrderID int;
	declare @ProductOrderID int;

	select @TerminalID = Terminal from Terminals where Terminal = 2;
	Begin
	    insert into Orders (ByTerminal, Paid)
	    values (@TerminalID, 1);
	    select @OrderID = SCOPE_IDENTITY();
	End

	Begin
	    insert into ProductOrders(Product, OrderId)
	    values (2, @OrderID);
	    select @ProductOrderID = SCOPE_IDENTITY();
	End

	Begin
	    insert into Stuffings(ProductOrder, Ingredient, Antal)
	    values (@ProductOrderID, 2, 1);
	    insert into Stuffings(ProductOrder, Ingredient, Antal)
	    values (@ProductOrderID, 4, 2);
	    insert into Stuffings(ProductOrder, Ingredient, Antal)
	    values (@ProductOrderID, 8, 1);
	End

	Begin
	    insert into ProductOrders(Product, OrderId)
	    values (3, @OrderID);
	    select @ProductOrderID = SCOPE_IDENTITY();
	End

	Begin
	    insert into Stuffings(ProductOrder, Ingredient, Antal)
	    values (@ProductOrderID, 6, 3);
	    insert into Stuffings(ProductOrder, Ingredient, Antal)
	    values (@ProductOrderID, 4, 2);
	    insert into Stuffings(ProductOrder, Ingredient, Antal)
	    values (@ProductOrderID, 7, 1);
	End
	GO
	declare @TerminalID int;
	declare @OrderID int;
	declare @ProductOrderID int;

	select @TerminalID = Terminal from Terminals where Terminal = 2;
	Begin
	    insert into Orders (ByTerminal, Paid)
	    values (@TerminalID, 1);
	    select @OrderID = SCOPE_IDENTITY();
	End

	Begin
	    insert into ProductOrders(Product, OrderId)
	    values (3, @OrderID);
	    select @ProductOrderID = SCOPE_IDENTITY();
	End

	Begin
	    insert into Stuffings(ProductOrder, Ingredient, Antal)
	    values (@ProductOrderID, 3, 2);
	    insert into Stuffings(ProductOrder, Ingredient, Antal)
	    values (@ProductOrderID, 5, 2);
	    insert into Stuffings(ProductOrder, Ingredient, Antal)
	    values (@ProductOrderID, 9, 1);
	End

	Begin
	    insert into ProductOrders(Product, OrderId)
	    values (3, @OrderID);
	    select @ProductOrderID = SCOPE_IDENTITY();
	End

	Begin
	    insert into Stuffings(ProductOrder, Ingredient, Antal)
	    values (@ProductOrderID, 7, 3);
	    insert into Stuffings(ProductOrder, Ingredient, Antal)
	    values (@ProductOrderID, 5, 2);
	    insert into Stuffings(ProductOrder, Ingredient, Antal)
	    values (@ProductOrderID, 6, 1);
	End
GO
	declare @TerminalID int;
	declare @OrderID int;
	declare @ProductOrderID int;

	select @TerminalID = Terminal from Terminals where Terminal = 2;
	Begin
	    insert into Orders (ByTerminal, Paid)
	    values (@TerminalID, 0);
	    select @OrderID = SCOPE_IDENTITY();
	End

	Begin
	    insert into ProductOrders(Product, OrderId)
	    values (2, @OrderID);
	    select @ProductOrderID = SCOPE_IDENTITY();
	End

	Begin
	    insert into Stuffings(ProductOrder, Ingredient, Antal)
	    values (@ProductOrderID, 6, 1);
	    insert into Stuffings(ProductOrder, Ingredient, Antal)
	    values (@ProductOrderID, 7, 2);
	    insert into Stuffings(ProductOrder, Ingredient, Antal)
	    values (@ProductOrderID, 8, 1);
	End

	Begin
	    insert into ProductOrders(Product, OrderId)
	    values (3, @OrderID);
	    select @ProductOrderID = SCOPE_IDENTITY();
	End

	Begin
	    insert into Stuffings(ProductOrder, Ingredient, Antal)
	    values (@ProductOrderID, 10, 3);
	    insert into Stuffings(ProductOrder, Ingredient, Antal)
	    values (@ProductOrderID, 3, 2);
	    insert into Stuffings(ProductOrder, Ingredient, Antal)
	    values (@ProductOrderID, 2, 1);
	End


