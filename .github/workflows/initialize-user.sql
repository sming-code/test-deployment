-- Write your own SQL object definition here, and it'll be included in your package.
create user [$(CaName)] from external provider
go

alter role db_ddladmin add member [$(CaName)]
go

alter role db_datareader add member [$(CaName)]
go

alter role db_datawriter add member [$(CaName)]
go
