-- Write your own SQL object definition here, and it'll be included in your package.
create user [$(CaName)] from external provider
GO

alter role db_ddladmin add member [$(CaName)]
GO

alter role db_datareader add member [$(CaName)]
GO

alter role db_datawriter add member [$(CaName)]
GO
