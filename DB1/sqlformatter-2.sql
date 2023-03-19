CREATE TABLE CUSTOMER(
  CustomerID INTEGER PRIMARY KEY, 
  Name TEXT NOT NULL, 
  Email TEXT NOT NULL CHECK (Email LIKE "%@%"), 
  PhoneNo TEXT NOT NULL CHECK (
    length(PhoneNo) <= 15
  )
);

CREATE TABLE CAR_TYPE(
  Name TEXT PRIMARY KEY, 
  Type TEXT NOT NULL CHECK (
    Type == "Seating" 
    OR Type == "Sleeping"
  ), 
  NoRows INTEGER, 
  NoSeatsInRow INTEGER, 
  NoCompartments INTEGER, 
  CHECK (
    (
      Type == 'Seating' 
      AND NoRows IS NOT NULL 
      AND NoSeatsInRow IS NOT NULL 
      AND NoRows > 0 
      AND NoSeatsInRow > 0 
      AND NoCompartments IS NULL
    ) 
    OR (
      Type == 'Sleeping' 
      AND NoCompartments IS NOT NULL 
      AND NoRows IS NULL 
      AND NoSeatsInRow IS NULL 
      AND NoCompartments > 0
    )
  )
);
CREATE TABLE OPERATOR(
  OperatorID INTEGER PRIMARY KEY, Name TEXT NOT NULL
);
CREATE TABLE STATION(
  Name TEXT PRIMARY KEY, 
  --Check if altitude is roughly between the lowest and highest points on Earth.
  Altitude INTEGER NOT NULL CHECK (
    Altitude > -500 
    AND Altitude < 9000
  )
);
CREATE TABLE TRACK_SECTION(
  Name TEXT PRIMARY KEY, 
  DrivingEnergy TEXT NOT NULL CHECK (
    DrivingEnergy == "Diesel" 
    OR DrivingEnergy == "Electric"
  )
);
CREATE TABLE ROUTE(
  RouteID INTEGER PRIMARY KEY, 
  Name TEXT NOT NULL, 
  OperatorID INTEGER NOT NULL, 
  StartStationName TEXT NOT NULL, 
  EndStationName TEXT NOT NULL, 
  FOREIGN KEY (OperatorID) REFERENCES OPERATOR (OperatorID) ON DELETE CASCADE ON UPDATE CASCADE, 
  FOREIGN KEY (StartStationName) REFERENCES STATION (Name) ON DELETE CASCADE ON UPDATE CASCADE, 
  FOREIGN KEY (EndStationName) REFERENCES STATION (Name) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE ROUTE_WEEKDAY(
  RouteID INTEGER NOT NULL, 
  Weekday TEXT NOT NULL CHECK (Weekday LIKE "%day"), 
  PRIMARY KEY(RouteID, Weekday), 
  FOREIGN KEY (RouteID) REFERENCES ROUTE (RouteID) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE CUSTOMER_ORDER(
  OrderID INTEGER PRIMARY KEY, 
  CustomerID INTEGER NOT NULL, 
  DateTime TEXT NOT NULL CHECK (
    datetime(DateTime) IS NOT NULL
  ), 
  --Check that the year is roughly within the lifespan of railways.
  -- Allow for historical and future years.
  TripYear INTEGER NOT NULL CHECK (
    TripYear > 1800 
    AND TripYear < 3000
  ), 
  TripWeekNr INTEGER NOT NULL CHECK (
    TripWeekNr >= 1 
    AND TripWeekNr <= 53
  ), 
  StartStationName TEXT NOT NULL, 
  EndStationName TEXT NOT NULL, 
  RouteID INTEGER NOT NULL, 
  Weekday TEXT NOT NULL, 
  FOREIGN KEY (CustomerID) REFERENCES CUSTOMER (CustomerID) ON DELETE CASCADE ON UPDATE CASCADE, 
  FOREIGN KEY (StartStationName) REFERENCES STATION (Name) ON DELETE CASCADE ON UPDATE CASCADE, 
  FOREIGN KEY (EndStationName) REFERENCES STATION (Name) ON DELETE CASCADE ON UPDATE CASCADE, 
  FOREIGN KEY (RouteID, Weekday) REFERENCES ROUTE_WEEKDAY (RouteID, Weekday) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE ROUTE_STATION_TIME(
  RouteID INTEGER NOT NULL, 
  StationName TEXT NOT NULL, 
  TimeOfArrival TEXT CHECK (
    TimeOfArrival IS NULL 
    OR time(TimeOfArrival) IS NOT NULL
  ), 
  TimeOfDeparture TEXT CHECK (
    TimeOfDeparture IS NULL 
    OR time(TimeOfDeparture) IS NOT NULL
  ), 
  CHECK (TimeOfArrival IS NOT NULL OR TimeOfDeparture IS NOT NULL), 
  FOREIGN KEY (RouteID) REFERENCES ROUTE (RouteID) ON DELETE CASCADE ON UPDATE CASCADE, 
  FOREIGN KEY (StationName) REFERENCES STATION (Name) ON DELETE CASCADE ON UPDATE CASCADE, 
  PRIMARY KEY (
    RouteID, StationName, TimeOfArrival, 
    TimeOfDeparture
  )
);
CREATE TABLE ROUTE_TRACK_TRAVERSAL(
  RouteID INTEGER NOT NULL, 
  TrackSectionName TEXT NOT NULL, 
  Direction TEXT NOT NULL CHECK (
    Direction == "Main" 
    OR Direction == "Opposite"
  ), 
  FOREIGN KEY (RouteID) REFERENCES ROUTE (RouteID) ON DELETE CASCADE ON UPDATE CASCADE, 
  FOREIGN KEY (TrackSectionName) REFERENCES TRACK_SECTION (Name) ON DELETE CASCADE ON UPDATE CASCADE, 
  PRIMARY KEY(RouteID, TrackSectionName)
);
CREATE TABLE SUB_SECTION(
  Station1Name TEXT NOT NULL, 
  Station2Name TEXT NOT NULL, 
  SectionName TEXT NOT NULL, 
  -- Can’t have negative length, and it is probably not longer than the Trans-Siberian Railway.
  Length TEXT NOT NULL CHECK (
    Length > 0 
    AND Length < 10000
  ), 
  TrackType TEXT NOT NULL CHECK (
    TrackType == "Single" 
    OR TrackType == "Double"
  ), 
  FOREIGN KEY (Station1Name) REFERENCES STATION (Name) ON DELETE CASCADE ON UPDATE CASCADE, 
  FOREIGN KEY (Station2Name) REFERENCES STATION (Name) ON DELETE CASCADE ON UPDATE CASCADE, 
  FOREIGN KEY (SectionName) REFERENCES TRACK_SECTION (Name) ON DELETE CASCADE ON UPDATE CASCADE, 
  PRIMARY KEY (
    Station1Name, Station2Name, SectionName
  )
);
CREATE TABLE ARRANGED_CAR(
  RouteID INTEGER NOT NULL, 
  -- Number starts at 1 at the front, should not be more cars than the longest train in the world.
  Number INTEGER NOT NULL CHECK (
    Number > 0 
    AND Number < 300
  ), 
  CarTypeName TEXT NOT NULL, 
  FOREIGN KEY (RouteID) REFERENCES ROUTE (RouteID) ON DELETE CASCADE ON UPDATE CASCADE, 
  FOREIGN KEY (CarTypeName) REFERENCES CAR_TYPE (Name) ON DELETE CASCADE ON UPDATE CASCADE, 
  PRIMARY KEY(RouteID, Number)
);
CREATE TABLE PLACE(
  CarTypeName TEXT NOT NULL, 
  PlaceNo INTEGER NOT NULL, 
  FOREIGN KEY (CarTypeName) REFERENCES CAR_TYPE (Name) ON DELETE CASCADE ON UPDATE CASCADE, 
  PRIMARY KEY(CarTypeName, PlaceNo)
);
CREATE TABLE ORDER_PLACE(
  OrderID INTEGER NOT NULL, 
  CarTypeName TEXT NOT NULL, 
  PlaceNo INTEGER NOT NULL, 
  FOREIGN KEY (OrderID) REFERENCES CUSTOMER_ORDER (OrderId) ON DELETE CASCADE ON UPDATE CASCADE, 
  FOREIGN KEY (CarTypeName, PlaceNo) REFERENCES Place(CarTypeName, PlaceNo) ON DELETE CASCADE ON UPDATE CASCADE, 
  PRIMARY KEY(OrderID, CarTypeName, PlaceNo)
);
