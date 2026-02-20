[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
shared gprojeto = "credbi-perdizes" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true];
shared gdatabase = "bdnfe" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true];
shared RangeStart = #datetime(2024, 1, 1, 0, 0, 0) meta [IsParameterQuery=true, Type="DateTime", IsParameterQueryRequired=true];
shared RangeEnd = #datetime(2030, 12, 31, 0, 0, 0) meta [IsParameterQuery=true, Type="DateTime", IsParameterQueryRequired=true];
shared IDCliente = 1 meta [IsParameterQuery=true, Type="Number", IsParameterQueryRequired=true];
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "dNotas_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared dNotas = let
    // Conexão com o BigQuery
    Fonte = GoogleBigQuery.Database(),

    // Seleciona o projeto
    Projeto = Fonte{[Name = gprojeto]}[Data],

    // Seleciona o schema/dataset
    Schema = Projeto{[Name = gdatabase, Kind = "Schema"]}[Data],

    // Obtém a tabela de notas consolidadas
    DimNotas = Schema{[Name = "dim_notas_consolidadas", Kind = "Table"]}[Data],

    // Filtra por janela incremental de carga
    FiltraDataCarga =
        Table.SelectRows(
            DimNotas,
            each [DataCarga] >= RangeStart and [DataCarga] < RangeEnd
        ),

    // Filtra apenas registros do cliente informado
    FiltraCliente =
        Table.SelectRows(
            FiltraDataCarga,
            each [ClienteId] = IDCliente
        )
in
    FiltraCliente;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "fDocumentos_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared fDocumentos = let
    // Conexão com o BigQuery
    Fonte = GoogleBigQuery.Database(),

    // Seleciona o projeto
    Projeto = Fonte{[Name = gprojeto]}[Data],

    // Seleciona o schema/dataset
    Schema = Projeto{[Name = gdatabase, Kind = "Schema"]}[Data],

    // Obtém a tabela fato de documentos
    FactDocumentos = Schema{[Name = "fact_documentos", Kind = "Table"]}[Data],

    // Filtra por janela incremental de carga
    FiltraDataCarga =
        Table.SelectRows(
            FactDocumentos,
            each [DataCarga] >= RangeStart and [DataCarga] < RangeEnd
        ),

    // Filtra apenas registros do cliente informado
    FiltraCliente =
        Table.SelectRows(
            FiltraDataCarga,
            each [ClienteId] = IDCliente
        )
in
    FiltraCliente;
shared dNotas_DataDestination = let
  Pattern = Lakehouse.Contents([HierarchicalNavigation = null, CreateNavigationProperties = false, EnableFolding = false]),
  Navigation_1 = Pattern{[workspaceId = "3eb1a572-23f9-4615-9dd9-9c5a03e95de2"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "21dc259f-a161-44c2-9437-8d3deaeb906d"]}[Data],
  TableNavigation = Navigation_2{[Id = "dNotas", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared fDocumentos_DataDestination = let
  Pattern = Lakehouse.Contents([HierarchicalNavigation = null, CreateNavigationProperties = false, EnableFolding = false]),
  Navigation_1 = Pattern{[workspaceId = "3eb1a572-23f9-4615-9dd9-9c5a03e95de2"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "21dc259f-a161-44c2-9437-8d3deaeb906d"]}[Data],
  TableNavigation = Navigation_2{[Id = "fDocumentos", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
