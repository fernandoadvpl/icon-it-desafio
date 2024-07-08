#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} APICAR01

API responsável por retornar todos os títulos do contas a receber 

@author     Fernando Alves | @fernandoadvpl
@since 		08/07/2024
@version 	1.0 
@obs		Rotina Especifica Icon Solution
/*/
//-------------------------------------------------------------------

WSRESTFUL APICAR01 DESCRIPTION "API respnsável por retornar dados do Contas a Receber"

	WSDATA page      AS INTEGER OPTIONAL
	WSDATA pageSize  AS INTEGER OPTIONAL
    WSDATA company   AS STRING  OPTIONAL
	WSDATA branch    AS STRING  OPTIONAL

	WSMETHOD GET getcar DESCRIPTION "Retorna títulos a receber" ; 
                        WSSYNTAX    "/api/v1/getcar"            ; 
                        PATH        "api/v1/getcar"             ;
                        PRODUCES APPLICATION_JSON

END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} GET / getcar

Método GET responsável por consultar e retornar os dados do contas 
a receber de acordo com os parãmetros recebidos.

@param  Page     , N , Número da pagina a ser retornada 
        PageSize , N , Quantidade de registros por página
        Company  , C , Código da Empresa
        Branch   , C , Código da Filial

@return Nil
/*/
//-------------------------------------------------------------------

WSMETHOD GET getcar WSRECEIVE company, branch, page, pageSize WSREST APICAR01

Local aListCli     := {}

Local cAliasSE1    := GetNextAlias()
Local aSM0Data     := {}
Local lRet         := .T.

Local nCount       := 0
Local nStart       := 1
Local nReg         := 0
Local nAux         := 0
Local nTotalReg    := 0
Local nTotalPages  := 0

Local oJsonSE1     := JsonObject():New()
Local oError       := JsonObject():New()

Local cApiKey      := SuperGetMV("ES_APIKEY", .T., "Bearer AIzaSyD7jxQhHbdsULiVZCX6Ow0mXxWq6LzRDpA")
Local cKeyRes      := '' 

Default ::company  := '99'
Default ::branch   := '01'
Default ::page     := 1
Default ::pageSize := 10

::SetContentType("application/json")
cKeyRes := ::GetHeader("Authorization")

If cKeyRes == Alltrim(cApiKey)

    cEmpRes            := AllTrim( Upper( ::company ) )
    cFilRes            := AllTrim( Upper( ::branch ) )
    aSM0Data           := FWSM0Util():GetSM0Data( cEmpRes , cFilRes , { "M0_CODFIL" } )

    If Len(aSM0Data) > 0

        //-------------------------------------------------------------------
        // Query para selecionar os títulos do contas a receber
        //-------------------------------------------------------------------
        BeginSQL Alias cAliasSE1

            COLUMN E1_EMISSAO AS DATE
            COLUMN E1_VENCTO  AS DATE
            COLUMN E1_VENCREA AS DATE        
        
            SELECT  E1_FILIAL   , E1_PREFIXO  , E1_NUM      , E1_PARCELA,
                    E1_EMISSAO  , E1_VENCTO   , E1_VENCREA  , E1_VALOR
            FROM %Table:SE1% SE1
            WHERE E1_FILIAL = %Exp:cFilRes% 
            AND SE1.%NotDel%
        
        EndSQL

        If (cAliasSE1)->(!Eof())

            //-------------------------------------------------------------------
            // Identifica a quantidade de registro no alias temporário
            //-------------------------------------------------------------------
            COUNT TO nTotalReg

            //-------------------------------------------------------------------
            // Calcula o total de páginas
            //-------------------------------------------------------------------
            nTotalPages := Int( nTotalReg / ::pageSize )
            If ( nTotalReg % ::pageSize ) > 0
                nTotalPages++
            EndIf

            //-------------------------------------------------------------------
            // nStart -> primeiro registro da pagina
            // nReg -> numero de registros do inicio da pagina ao fim do arquivo
            //-------------------------------------------------------------------
            If ::page > 1
                nStart  := ( ( ::page - 1 ) * ::pageSize ) + 1
                nReg    := nTotalReg - nStart + 1
            Else
                nReg := nTotalReg
            EndIf

            //-------------------------------------------------------------------
            // Posiciona no primeiro registro.
            //-------------------------------------------------------------------
            ( cAliasSE1 )->( DBGoTop() )

            //-------------------------------------------------------------------
            // Valida a existência de mais páginas
            //-------------------------------------------------------------------
            If nReg > ::pageSize
                oJsonSE1['hasNext'] := .T.
            Else
                oJsonSE1['hasNext'] := .F.
            EndIf
        Else
            //-------------------------------------------------------------------
            // Não encontrou registros
            //-------------------------------------------------------------------
            oJsonSE1['hasNext'] := .F.
        EndIf


        //-------------------------------------------------------------------
        // Alimenta array de títulos
        //-------------------------------------------------------------------
        While ( cAliasSE1 )->( ! Eof() )

            nCount++

            If nCount >= nStart

                nAux++
                aAdd( aListCli , JsonObject():New() )

                aListCli[nAux]['branch']        := Alltrim((cAliasSE1)->E1_FILIAL)
                aListCli[nAux]['prefix']        := Alltrim((cAliasSE1)->E1_PREFIXO)
                aListCli[nAux]['number']        := Alltrim((cAliasSE1)->E1_NUM)
                aListCli[nAux]['installment']   := Alltrim((cAliasSE1)->E1_PARCELA)
                aListCli[nAux]['issue']         := StrTran(DtoC((cAliasSE1)->E1_EMISSAO),'/','-')
                aListCli[nAux]['dueDate']       := StrTran(DtoC((cAliasSE1)->E1_VENCTO),'/','-')
                aListCli[nAux]['actualDueDate'] := StrTran(DtoC((cAliasSE1)->E1_VENCREA),'/','-')
                aListCli[nAux]['amount']        := (cAliasSE1)->E1_VALOR
                aListCli[nAux]['currency']      := 'R$ ' + Alltrim(Transform((cAliasSE1)->E1_VALOR , "@E 999,999,999.99"))

                If Len(aListCli) >= ::pageSize
                    Exit
                EndIf

            EndIf

            ( cAliasSE1 )->( DbSkip() )

        EndDo

        ( cAliasSE1 )->( DbCloseArea() )

        oJsonSE1['invoices'] := aListCli

        //-------------------------------------------------------------------
        // Adiciona informações de paginação ao JSON
        //-------------------------------------------------------------------
        oJsonSE1['totalRecords'] := nTotalReg
        oJsonSE1['currentPage']  := ::page
        oJsonSE1['totalPages']   := nTotalPages

        //-------------------------------------------------------------------
        // Serializa objeto Json
        //-------------------------------------------------------------------
        cJsonCli := FwJsonSerialize( oJsonSE1 )

        //-------------------------------------------------------------------
        // Elimina objeto da memoria
        //-------------------------------------------------------------------
        FreeObj(oJsonSE1)

        ::SetResponse( cJsonCli ) 

    Else
        lRet := .F.
        oError['status'] := 400
        oError['message'] := "Empresa ou filial informada não é válida."
        SetRestFault(403, EncodeUTF8(FwJsonSerialize(oError)))
        FreeObj(oError)
    EndIf
Else
    lRet := .F.
    oError['status'] := 403
    oError['message'] := "Acesso não autorizado! API Key inválida ou não informada."    
    SetRestFault(403, EncodeUTF8(FwJsonSerialize(oError)))
    FreeObj(oError)
EndIf

Return( lRet )
