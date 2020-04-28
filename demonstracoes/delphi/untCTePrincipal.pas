unit untCTePrincipal;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, IniFiles, spdCTeXMLUtils, spdCTeType, spdCTe,
  spdCTeException, spdCustomCTe, spdCTeUtils, spdCteDataSet, spdCCeCTeDataSetAdapter,
  StdCtrls, ExtCtrls, ComCtrls, DateUtils, Buttons, ShellApi;

type
  TfrmCTePrincipal = class(TForm)
    Panel2: TPanel;
    GroupBox2: TGroupBox;
    Label5: TLabel;
    edtDirEsquemas: TEdit;
    Panel1: TPanel;
    Panel4: TPanel;
    Panel3: TPanel;
    sbPreencherComp: TSpeedButton;
    sbGerarXML: TSpeedButton;
    pcProcessos: TPageControl;
    sbGerarTX2: TSpeedButton;
    tsTX2: TTabSheet;
    GroupBox5: TGroupBox;
    mmTX2: TMemo;
    sbAssinar: TSpeedButton;
    tsXML: TTabSheet;
    GroupBox6: TGroupBox;
    mmXML: TMemo;
    sbEnviar: TSpeedButton;
    edtCNPJEmitente: TEdit;
    Label3: TLabel;
    sbLimpar: TSpeedButton;
    Panel5: TPanel;
    GroupBox9: TGroupBox;
    cbCertificado: TComboBox;
    lbl1: TLabel;
    Ambiente: TLabel;
    cbAmbiente: TComboBox;
    lbl2: TLabel;
    cbVersao: TComboBox;
    GroupBox3: TGroupBox;
    mmXMLAssinado: TMemo;
    tsEnvio: TTabSheet;
    GroupBox7: TGroupBox;
    mmEnvio: TMemo;
    tsConsulta: TTabSheet;
    GroupBox10: TGroupBox;
    sbConsultaLote: TSpeedButton;
    mmConsulta: TMemo;
    sbConsultarRecibo: TSpeedButton;
    tsXMLEnviado: TTabSheet;
    tsXMLRetornado: TTabSheet;
    GroupBox8: TGroupBox;
    mmXMLRetorno: TMemo;
    GroupBox11: TGroupBox;
    mmXMLEnvio: TMemo;
    sbExcluir: TSpeedButton;
    tsExclusao: TTabSheet;
    GroupBox12: TGroupBox;
    mmTX2Exclusao: TMemo;
    GroupBox13: TGroupBox;
    mmXMLExclusao: TMemo;
    GroupBox14: TGroupBox;
    mmRetornoExclusao: TMemo;
    SpeedButton1: TSpeedButton;
    GroupBox4: TGroupBox;
    edtRecibo: TEdit;
    GroupBox15: TGroupBox;
    Label4: TLabel;
    Label6: TLabel;
    EdtCNPJ: TEdit;
    edtToken: TEdit;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    edtModelo: TEdit;
    edtSerie: TEdit;
    edtNumeroCTe: TEdit;
    edtCodigo: TEdit;
    cbTipoTransp: TComboBox;
    Label2: TLabel;
    cbTipoUnidade: TComboBox;
    Label10: TLabel;
    edtIDUnidade: TEdit;
    Label11: TLabel;
    edtArqTX2: TEdit;
    Label12: TLabel;
    GroupBox16: TGroupBox;
    edtChave: TEdit;
    edtProtocolo: TEdit;
    Label13: TLabel;
    edtDirTemplates: TEdit;
    Label14: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure sbPreencherCompClick(Sender: TObject);
    procedure sbGerarXMLClick(Sender: TObject);
    procedure sbGerarTX2Click(Sender: TObject);
    procedure sbAssinarClick(Sender: TObject);
    procedure sbEnviarClick(Sender: TObject);
    procedure sbLimparClick(Sender: TObject);
    procedure Label6Click(Sender: TObject);
    procedure sbConsultaLoteClick(Sender: TObject);
    procedure sbConsultarReciboClick(Sender: TObject);
    procedure sbExcluirClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SomenteNumero(Sender: TObject; var Key: Char);
  private
    procedure CarregarDadosReinf;
    procedure Limpar;
    procedure GerarTX2Exclusao;
    procedure EnviarExclusao;
    procedure GerarXMLAssinado;
    procedure PreencherTX2;
    function GetChave: string;
    function DigitoMod11(pNumero: string): Integer;
    function GetVersao(const AFileName: String): String;
    { Private declarations }
  public
    { Public declarations }
    vCTe        : TspdCTe;
    vCTeDataSet : TspdCTeDataSet;
    vCTeUtils   : TspdCTeUtils;
    vArquivoIni : TIniFile;
  end;

var
  frmCTePrincipal: TfrmCTePrincipal;

implementation

uses spdXMLUtils, Math;

{$R *.dfm}

{
** ERROS **
===============================================================================
==
=>
===============================================================================
}

function TfrmCTePrincipal.GetVersao(const AFileName: String): String;
var
  FileName: string;
  InfoSize, Wnd: DWORD;
  VerBuf: Pointer;
  FI: PVSFixedFileInfo;
  VerSize: DWORD;
begin
  Result := EmptyStr;
  FileName := AFileName;
  UniqueString(FileName);
  InfoSize := GetFileVersionInfoSize(PChar(FileName), Wnd);
  if InfoSize <> 0 then
  begin
    GetMem(VerBuf, InfoSize);
    try
      if GetFileVersionInfo(PChar(FileName), Wnd, InfoSize, VerBuf) then
        if VerQueryValue(VerBuf, '\', Pointer(FI), VerSize) then
          Result:= Concat(IntToStr(FI.dwFileVersionMS shr 16), '.',
                          IntToStr(FI.dwFileVersionMS and $FFFF), '.',
                          IntToStr(FI.dwFileVersionLS shr 16), '.',
                          IntToStr(FI.dwFileVersionLS and $FFFF));
    finally
      FreeMem(VerBuf);
    end;
  end;
end;

Function TfrmCTePrincipal.DigitoMod11(pNumero: string): Integer;
var
  vCadeia   : String;
  vX        : Integer;
  vY        : Integer;
  vValor    : Integer;
  vDigito   : Integer;
  vPosicao  : String;
  vPosicaoI : Integer;
Begin
   vValor := 0;
   vCadeia := pNumero;

   For vY := 2 DownTo 1 do
   Begin
      For vX := 9 DownTo 1 do
      Begin
         vPosicao    := Copy( vCadeia, ( 17 - ( vX + ( 9 * ( vY - 1 ) ) ) ), 1 );
         vPosicaoI    := StrToInt( vPosicao );
         vValor      := vValor + ( vPosicaoI * ( vX + 1 ) )
      End;
   End;
 
   vDigito := ( ( vValor * 10 ) mod 11 );

   If vDigito >= 10 Then
      vDigito := 0;
 
   Result := vDigito;
 
End;

procedure TfrmCTePrincipal.CarregarDadosReinf;
begin
  edtCNPJ.Text             := vArquivoIni.ReadString('CTE','CNPJ','');
  edtTOKEN.Text            := vArquivoIni.ReadString('CTE','TOKENSH','');
  edtCNPJEmitente.Text     := vArquivoIni.ReadString('CTE','CNPJ','');

  edtDirEsquemas.Text      := vArquivoIni.ReadString('CTE','DiretorioEsquemas','');
  edtDirTemplates.Text     := vArquivoIni.ReadString('CTE','DiretorioTemplates','');
  edtArqTX2.Text           := GetCurrentDir + '\Arq.TX2';
  cbVersao.Items.Text      := vCTe.Versao;

  vCTe.ListarCertificados(cbCertificado.Items);
{
  Quando o ListarCertificados n�o trouxer nada, verificar se o certificado foi instalado por maquina ou por usu�rio
}
  cbVersao.ItemIndex       := 0;
  cbCertificado.ItemIndex  := 0;
end;

procedure TfrmCTePrincipal.Limpar;
begin
  edtChave.Text  := '';
  edtRecibo.Text := '';

  pcProcessos.ActivePage := tsTX2;
end;

procedure TfrmCTePrincipal.FormCreate(Sender: TObject);
begin
  Limpar;
  vCTe        := TspdCTe.Create(nil);
  vCTeDataSet := TspdCTeDataSet.Create(nil);
  vCTeUtils   := TspdCTeUtils.Create;
  
  vArquivoIni := TIniFile.Create(ChangeFileExt(Application.ExeName,'.ini'));

  frmCTePrincipal.Caption := 'Demonstra��o CT-e v.' + vCTe.Versao + ' - TecnoSpeed';
end;

procedure TfrmCTePrincipal.FormShow(Sender: TObject);
begin
  CarregarDadosReinf;
end;

procedure TfrmCTePrincipal.sbPreencherCompClick(Sender: TObject);
begin
  try
    vCTe.ConfigurarSoftwareHouse(edtCNPJ.Text, edtTOKEN.Text);

    vCTe.UF       := 'PR';                              //valor aceito 'PR';

    if cbAmbiente.ItemIndex = 0 then //1 - Produ��o; 2 - Homologa��o;
      vCTe.Ambiente := akProducao
    else
      vCTe.Ambiente := akHomologacao;

    vCTe.CNPJ                       := edtCNPJEmitente.Text;    //CNPJ completo do Emitente;
    vCTe.NomeCertificado.Text       := cbCertificado.Text;
    vCTe.DiretorioLog               := 'C:\Program Files\TecnoSpeed\CTe\Arquivos\Logs';
    vCTe.DiretorioXmlTomadorServico := 'C:\Program Files\TecnoSpeed\CTe\Arquivos\XMLTomador';
    vCTe.DiretorioEsquemas  := edtDirEsquemas.Text + 'Esquemas\';     //Diret�rio dos schemas;
    vCTe.DiretorioTemplates := edtDirEsquemas.Text + 'Templates\';
    vCTe.MappingFileName    := 'MappingCTe.txt';
    vCTe.VersaoManual       := vm300a;

    edtChave.Text := getChave;
{ Necess�rio apenas para certificado A1
        vCTe.SenhaCertificado := '';
}
{ Senha do certificado A3, caso queira autentica��o autom�tica
        vCTe.Pincode := '';
}
{ Configura��es necess�rias apenas para proxy
        vCTe.Proxy := '';
        vCTe.Usuario := '';
        vCTe.Senha := '';
}
    ShowMessage('Configurado com sucesso.');

  except
    on e : exception do
     showmessage('Ocorreu o seguinte erro: '+ e.message);
  end;
end;

function TfrmCTePrincipal.GetChave: string;
var
  vChave: string;
  vData : string;
  vCodigoUF: string;
  vTpEmiss: string;
begin
    vCodigoUF := IntToStr(vCTe.ObterCodigoUF(vCTe.UF));
    vData     := FormatDateTime('yyyy-mm-dd', Now);
    vTpEmiss  := '1';  // Tipo de emiss�o: "1-Normal�, �5-Conting�ncia FS-DA�, �7-Autoriza��o pela SVC-RS�, �8-Autoriza��o pela SVC-SP�;

    {
    O CT-e, modelo 57, poder� ser utilizado pelos contribuintes do ICMS em substitui��o aos seguintes documentos:
      I - Conhecimento de Transporte Rodovi�rio de Cargas, modelo 8;
      II - Conhecimento de Transporte Aquavi�rio de Cargas, modelo 9;
      III - Conhecimento A�reo, modelo 10;
      IV - Conhecimento de Transporte Ferrovi�rio de Cargas, modelo 11;
      V - Nota Fiscal de Servi�o de Transporte Ferrovi�rio de Cargas, modelo 27;
      VI - Nota Fiscal de Servi�o de Transporte, modelo 7, quando utilizada em transporte de cargas.
    }
    if (edtModelo.text = '')
    or (edtSerie.text = '')
    or (edtNumeroCTe.text = '')
    or (edtCodigo.text = '') then
    begin
      ShowMessage('Favor preencher todos os campos para gera��o da chave');
      Exit;
    end;

    vChave    := vCTe.CalculaChave(vCodigoUF, vData, vCTe.CNPJ, edtModelo.text, edtSerie.text, edtNumeroCTe.text, edtCodigo.text, vTpEmiss);

    sleep(2000);
    Result := vChave;
end;

procedure TfrmCTePrincipal.PreencherTX2;
begin
    mmTX2.Lines.Add('INCLUIR');

    //## infCTe ## - Informa��es do CTE
    mmTX2.Lines.Add('versao_2=3.00a');
    mmTX2.Lines.Add('id_3=' + edtChave.text);//Informar a chave de acesso do CT-e adquirida no m�todo vCTe.CalculaChave
    mmTX2.Lines.Add('cUF_5=' + IntToStr(vCTe.ObterCodigoUF(vCTe.UF)));//Utilizar a Tabela do IBGE ou m�todo vCTe.ObterCodigoUF.
    mmTX2.Lines.Add('cCT_6=' + edtCodigo.text);//N�mero aleat�rio gerado pelo emitente para cada CT-e, com o objetivo de evitar acessos indevidos ao documento.
    mmTX2.Lines.Add('CFOP_7=5351');//C�digo Fiscal de Opera��es e Presta��es
                                   //C�digo CFOP	Descri��o
                                   //   5.351 ou 6.351	Presta��o de servi�o de transporte para execu��o de servi�o da mesma natureza
                                   //   5.352 ou 6.352	Presta��o de servi�o de transporte a estabelecimento industrial
                                   //   5.353 ou 6.353	Presta��o de servi�o de transporte a estabelecimento comercial
                                   //   5.354 ou 6.354	Presta��o de servi�o de transporte a estabelecimento de prestador de servi�o de comunica��o
                                   //   5.355 ou 6.355	Presta��o de servi�o de transporte a estabelecimento de geradora ou de distribuidora de energia el�trica
                                   //   5.356 ou 6.356	Presta��o de servi�o de transporte a estabelecimento de produtor rural
                                   //   5.357 ou 6.357	Presta��o de servi�o de transporte a n�o contribuinte
                                   //   5.359 ou 6.359	Presta��o de servi�o de transporte a contribuinte ou a n�o-contribuinte, quando a mercadoria transportada esteja dispensada de emiss�o de Nota Fiscal
                                   //   5.360 ou 6.360	Presta��o de servi�o de transporte a contribuinte-substituto em rela��o ao servi�o de transporte
                                   //   5.932 ou 6.932	Presta��o de servi�o de transporte iniciada em unidade da Federa��o diversa daquela onde inscrito o prestador

    mmTX2.Lines.Add('natOp_8=TECNOSPEED TESTES E TRANSPORTES');//Nome do estabelecimento
    mmTX2.Lines.Add('mod_10=' + edtModelo.Text);//Utilizar o c�digo 57 para identifica��o do CT-e, emitido em substitui��o aos modelos de conhecimentos em papel.
    mmTX2.Lines.Add('serie_11=' + edtSerie.Text);//Preencher com "0" no caso de s�rie �nica
    mmTX2.Lines.Add('nCT_12=' + edtNumeroCTe.Text);
    mmTX2.Lines.Add('dhEmi_13=' + FormatDateTime('yyyy-mm-dd HH:MM:DD',now));//Data e hora de emiss�o do CT-e
    mmTX2.Lines.Add('tpImp_14=1');//1 � Retrato; 2 � Paisagem.
    mmTX2.Lines.Add('tpEmis_15=1');//1 � Normal; 4 � EPEC pela SVC; 5 � Conting�ncia FSDA; 7 � Autoriza��o pela SVC-RS; 8 � Autoriza��o pela SVC-SP.
    if edtChave.Text <> '' then
      mmTX2.Lines.Add('cDV_16=' + IntToStr(DigitoMod11(edtChave.Text)))
    else
      mmTX2.Lines.Add('cDV_16=0');
    mmTX2.Lines.Add('tpAmb_17=' + IntToStr(cbAmbiente.ItemIndex + 1));//1 - Produ��o; 2 - Produ��o restrita - dados reais;
    mmTX2.Lines.Add('tpCTe_18=0');//0 � CT-e Normal; 1 � CT-e de Complemento de Valores; 2 � CT-e de Anula��o de Valores; 3 � CT-e Substituto;
    mmTX2.Lines.Add('procEmi_19=0');//0 � emiss�o de CT-e com aplicativo do contribuinte; 1 � emiss�o de CT-e avulsa pelo Fisco;
                                    //2 � emiss�o de CT-e avulsa, pelo contribuinte com se certificado digital atrav�s do site do Fisco;
                                    //3 � emiss�o CT-e pelo contribuinte com aplicativo fornecido pelo Fisco.

    mmTX2.Lines.Add('verProc_20=' + GetVersao(Application.ExeName));//Informar a vers�o do aplicativo emissor de CT-e.
////    mmTX2.Lines.Add('indGlobalizado_1405=1');//Informar valor 1 quando for globalizado e n�o informar a tag nas demais situa��es
    mmTX2.Lines.Add('cMunEnv_672=4115200');//munic�pio onde o CT-e est� sendo transmitido. Utilizar a tabela do IBGE. Informar 9999999 para as opera��es com o exterior
    mmTX2.Lines.Add('xMunEnv_673=');//Informar PAIS/Municipio para as OPERA��ES COM O EXTERIOR.
    mmTX2.Lines.Add('UFEnv_674=PR');//Sigla UF, informar 'EX' para opera��es com o exterior.
    mmTX2.Lines.Add('modal_25=0' + IntToStr(cbTipoTransp.ItemIndex + 1));//01 � Rodovi�rio; 02 � A�reo; 03 � Aquavi�rio; 04 � Ferrovi�rio; 05 � Dutovi�rio; 06 � Multimodal;
    mmTX2.Lines.Add('tpServ_26=0');//0 � Normal; 1 � Subcontrata��o; 2 � Redespacho; 3 � Redespacho Intermedi�rio; 4 � Servi�o Vinculado a Multimodal.
    mmTX2.Lines.Add('cMunIni_27=4115200');//Munic�pio de in�cio da presta��o. Utilizar a tabela do IBGE. Informar 9999999 para opera��es com o exterior.
    mmTX2.Lines.Add('xMunIni_28=MARINGA');//Nome do munic�pio do in�cio da presta��o. 'EXTERIOR' para opera��es com o exterior.
    mmTX2.Lines.Add('UFIni_29=PR');//UF do in�cio da presta��o. 'EX' para opera��es com o exterior.
    mmTX2.Lines.Add('cMunFim_30=4115200');//Munic�pio do final da presta��o. Utilizar a tabela do IBGE. Informar 9999999 para opera��es com o exterior.
    mmTX2.Lines.Add('xMunFim_31=MARINGA');//Nome do munic�pio do final da presta��o. 'EXTERIOR' para opera��es com o exterior.
    mmTX2.Lines.Add('UFFim_32=PR');//UF do final da presta��o. 'EX' para opera��es com o exterior.
    mmTX2.Lines.Add('retira_33=1');//0 � Sim; 1 � N�o; Se o Recebedor retira no Aeroporto, Filial, Porto ou Esta��o de Destino
////    mmTX2.Lines.Add('xDetRetira_34=');//Detalhes do retirador
    mmTX2.Lines.Add('indIEToma_1406=2');//1 � Contribuinte ICMS; 2 � Contribuinte isento de inscri��o; 9 � N�o Contribuinte; OBS:Aplica-se ao tomador que for indicado no toma3 ou toma4

    //## toma3 ## Dados Tomador
    mmTX2.Lines.Add('toma_36=0');//0 � Remetente; 1 � Expedidor; 2 � Recebedor; 3 � Destinat�rio;

    //## toma4 ## Dados Tomador
    mmTX2.Lines.Add('toma_38=4');//4 � Outros.
    mmTX2.Lines.Add('CNPJ_39=08187168000160');//CNPJ completo, somente n�meros. Em caso de empresa n�o estabelecida no Brasil, ser� informado o CNPJ com zeros.
    mmTX2.Lines.Add('CPF_40=00000000000');//CPF completo, somente n�meros. Preencher com zero caso seja PJ
////    mmTX2.Lines.Add('IE_41=');//Informar a IE do tomador ou ISENTO se tomador � contribuinte do ICMS isento de inscri��o no cadastro de contribuintes do ICMS. Caso o tomador n�o seja contribuinte do ICMS n�o informar o conte�do.
    mmTX2.Lines.Add('xNome_42=Tecnospeed Teste');//Raz�o Social ou Nome
////    mmTX2.Lines.Add('xFant_43=Tecnospeed');//Nome fantasia
////    mmTX2.Lines.Add('fone_44=4435452585');

    //## enderToma ## Endere�o do Tomador
    mmTX2.Lines.Add('xLgr_46=Av Teste de Envioo');//Logradouro
    mmTX2.Lines.Add('nro_47=12345');//Numero
////    mmTX2.Lines.Add('xCpl_48=Apto 111');//Complemento
    mmTX2.Lines.Add('xBairro_49=Jardim Imperial');//Bairro
    mmTX2.Lines.Add('cMun_50=4115200');//Codigo munic�pio. Utilizar a tabela do IBGE. Informar 9999999 para opera��es com o exterior.
    mmTX2.Lines.Add('xMun_51=MARINGA');//Nome do munic�pio. 'EXTERIOR' para opera��es com o exterior.
    mmTX2.Lines.Add('CEP_52=00000000');
    mmTX2.Lines.Add('UF_53=PR');//UF. 'EX' para opera��es com o exterior.
    mmTX2.Lines.Add('cPais_54=1058');//Codigo do Pa�s. Utilizar a tabela do BACEN (Brasil 1058)
    mmTX2.Lines.Add('xPais_55=BRASIL');
////    mmTX2.Lines.Add('Email_601=teste@gmail.com');
    mmTX2.Lines.Add('dhCont_602=');//Data e Hora da entrada em contig�ncia
    mmTX2.Lines.Add('xJust_603=');//Justificativa da entrada em contig�ncia

    //## compl ## Dados complementares do CT-e para fins operacionais ou comerciais
////    mmTX2.Lines.Add('xCaracAd_57=');
////    mmTX2.Lines.Add('xCaracSer_58=');
////    mmTX2.Lines.Add('xEmi_59=');

    {################### AEREO #####################################}

    if cbTipoTransp.ItemIndex = 1 then
    begin
    //## fluxo ##  - Modal AEREO
      mmTX2.Lines.Add('xOrig_61=MGF');//Sigla ou c�digo interno da Filial/Porto/Esta��o/Aeroporto de Origem
                                      //Observa��es para o modal a�reo: - Preenchimento obrigat�rio para o modal a�reo.
                                      //- O c�digo de tr�s letras IATA do aeroporto de partida dever� ser inclu�do como primeira anota��o. Quando n�o for poss�vel, utilizar a sigla OACI.
    //## pass ##
      mmTX2.Lines.Add('xPass_63=CWB');//Sigla ou c�digo interno da Filial/Porto/Esta��o/Aeroporto de Passagem
                                      //- O c�digo de tr�s letras IATA, referente ao aeroporto de transfer�ncia, dever� ser inclu�do, quando for o caso.
                                      //Quando n�o for poss�vel, utilizar a sigla OACI. Qualquer solicita��o de itiner�rio dever� ser inclu�da.
      mmTX2.Lines.Add('xDest_64=CWB');//Sigla ou c�digo interno da Filial/Porto/Esta��o/Aeroporto de destino
                                      //- O c�digo de tr�s letras IATA, referente ao aeroporto de transfer�ncia, dever� ser inclu�do, quando for o caso.
                                      //Quando n�o for poss�vel, utilizar a sigla OACI. Qualquer solicita��o de itiner�rio dever� ser inclu�da.
////    mmTX2.Lines.Add('xRota_65=1');//C�digo da Rota de Entrega
    end;

    //## Entrega ##
    //  ## semData ##
////    mmTX2.Lines.Add('tpPer_68=0');//Tipo de data/per�odo programado para entrega; 0 � sem data definida.

    //  ## comData ##
    mmTX2.Lines.Add('tpPer_70=2');//Tipo de data/per�odo programado para entrega; 1 � na data; 2 � At� a data; 3 � A partir da data;
    mmTX2.Lines.Add('dProg_71=' + FormatDateTime('yyyy-mm-dd',now+30));//Data programada. Formato AAAA-MM-DD.

    //  ## noPeriodo ## - Entrega no per�odo definido
////    mmTX2.Lines.Add('tpPer_73=4');//Tipo per�odo. 4 - no per�odo.
////    mmTX2.Lines.Add('dIni_74=' + FormatDateTime('yyyy-mm-dd',now+30));//DataInicial. Formato AAAA-MM-DD.
////    mmTX2.Lines.Add('dFim_75=' + FormatDateTime('yyyy-mm-dd',now+60));//DataFinal. Formato AAAA-MM-DD.

    //  ## semHora ##
    mmTX2.Lines.Add('tpHor_77=0');//0- Sem hora definida

    //  ## comHora ##
////    mmTX2.Lines.Add('tpHor_79=1');//1 � No hor�rio; 2 � At� o hor�rio; 3 � A partir do hor�rio;
////    mmTX2.Lines.Add('hProg_80=12:00:00');//Hora programada. Formato HH:MM:SS.

    //  ## noInter ## - Entrega no intervalo de hor�rio definido.
////    mmTX2.Lines.Add('tphor_82=4');//4 � No intervalo de tempo
////    mmTX2.Lines.Add('hIni_83=12:00:00');//Hora final; Formato HH:MM:SS
////    mmTX2.Lines.Add('hFim_84=18:00:00');//Hora final; Formato HH:MM:SS
////    mmTX2.Lines.Add('origCalc_85=CURITIBA');//Munic�pio de origem para efeito de c�lculo do frete.
////    mmTX2.Lines.Add('destCalc_86=MARINGA');//Munic�pio de destino para efeito de c�lculo do frete.
////    mmTX2.Lines.Add('xObs_87=');//Observa��es gerais

    //## ObsCont ## - Campo de uso livre do contribuinte
////    mmTX2.Lines.Add('xCampo_89=');//Identifica��o do campo
////    mmTX2.Lines.Add('xTexto_90=');//Conte�do do campo

    //## ObsFisco ## - Campo de uso livre do contribuinte
////    mmTX2.Lines.Add('xCampo_92=');//Identifica��o do campo
////    mmTX2.Lines.Add('xTexto_93=');//Conte�do do campo

    //## emit ## - Identifica��o do Emitente do CT-e
    mmTX2.Lines.Add('CNPJ_95=62135817000124');//CNPJ do emitente
    mmTX2.Lines.Add('IE_96=0892386170');//Inscri��o Estadual do emitente
////    mmTX2.Lines.Add('IEST_1572=');//Inscri��o Estadual do Substituto Tribut�rio
    mmTX2.Lines.Add('xNome_97=Emitente Teste LTDA');//Raz�o social ou Nome do emitente
    mmTX2.Lines.Add('xFant_98=Emitente Teste Demonstra��o');//Nome fantasia

    //## enderEmit ## - Endere�o do emitente
    mmTX2.Lines.Add('xLgr_100=Avenida Brasil');//Logradouro
    mmTX2.Lines.Add('nro_101=1545');//numero
    mmTX2.Lines.Add('xCpl_102=Apto 10 B');//Complemento
    mmTX2.Lines.Add('xBairro_103=Jardim II');//Bairro
    mmTX2.Lines.Add('cMun_104=4115200');//Codigo IBGE do Munic�pio. Informar 9999999 para opera��es com o exterior.
    mmTX2.Lines.Add('xMun_105=MARINGA');//Nome Munic�pio. Informar EXTERIOR para opera��es com o exterior.
    mmTX2.Lines.Add('CEP_106=87023000');
    mmTX2.Lines.Add('UF_107=PR');//Informar EX para opera��es com o exterior.
    mmTX2.Lines.Add('fone_110=4433112255');

    //## rem ## - Identifica��o do Remetente do CT-e
    mmTX2.Lines.Add('CNPJ_112=05089180000143');//CNPJ do Remetente PJ
////    mmTX2.Lines.Add('CPF_113=');//CPF do Remetente PF
    mmTX2.Lines.Add('IE_114=5277964157');//Informar a IE do remetente ou ISENTO se remetente � contribuinte do ICMS isento de inscri��o no cadastro de contribuintes do ICMS. Caso o remetente n�o seja contribuinte do ICMS n�o informar a tag.
    mmTX2.Lines.Add('xNome_115=Remetente teste');//Raz�o social ou nome do remetente
    mmTX2.Lines.Add('xFant_116=Remetente teste');//Nome fantasia
    mmTX2.Lines.Add('fone_117=4435353535');

    //## enderReme ## - Endere�o do Remetente
    mmTX2.Lines.Add('xLgr_119=Rua Castro');//Logradouro
    mmTX2.Lines.Add('nro_120=111');//numero
    mmTX2.Lines.Add('xCpl_121=');//Complemento
    mmTX2.Lines.Add('xBairro_122=Paris III');//Bairro
    mmTX2.Lines.Add('cMun_123=4115200');//Codigo IBGE do Munic�pio. Informar 9999999 para opera��es com o exterior.
    mmTX2.Lines.Add('xMun_124=MARINGA');//Nome Munic�pio. Informar EXTERIOR para opera��es com o exterior.
    mmTX2.Lines.Add('CEP_125=87023033');
    mmTX2.Lines.Add('UF_126=PR');
    mmTX2.Lines.Add('cPais_127=1058');//Codigo do pa�s. Utilizar a tabela do BACEN.
    mmTX2.Lines.Add('xPais_128=BRASIL');
    mmTX2.Lines.Add('email_604=teste@gmail.com');

    //## exped ## - Informa��es do Expedidor da Carga
    mmTX2.Lines.Add('CNPJ_165=04410368000189');
////    mmTX2.Lines.Add('CPF_166=');
    mmTX2.Lines.Add('IE_167=7985439979');
    mmTX2.Lines.Add('xNome_168=Teste Expedidor da Carga');
    mmTX2.Lines.Add('Fone_169=4111111111');

    //## enderExped ##
    mmTX2.Lines.Add('xLgr_171=Logr Teste Expedidor da Carga');
    mmTX2.Lines.Add('nro_172=11');
    mmTX2.Lines.Add('xCpl_173=Compl Expedidor');
    mmTX2.Lines.Add('xBairro_174=Bairro Expedidor');
    mmTX2.Lines.Add('cMun_175=4115200');
    mmTX2.Lines.Add('xMun_176=MARINGA');
    mmTX2.Lines.Add('CEP_177=87023000');
    mmTX2.Lines.Add('UF_178=PR');
    mmTX2.Lines.Add('cPais_179=1058');//Codigo do pa�s. Utilizar a tabela do BACEN.
    mmTX2.Lines.Add('xPais_180=BRASIL');
    mmTX2.Lines.Add('Email_606=testeExpedidor@gmail.com');

   //## receb ## - Informa��es do Recebedor da Carga
    mmTX2.Lines.Add('CNPJ_182=63275153000161');
////    mmTX2.Lines.Add('CPF_183=');
    mmTX2.Lines.Add('IE_184=9605939608');
    mmTX2.Lines.Add('xNome_185=Teste Recebedor da Carga');
    mmTX2.Lines.Add('fone_186=4122222222');

    //## enderReceb ##
    mmTX2.Lines.Add('xLgr_188=Logr Recebedor da Carga');
    mmTX2.Lines.Add('nro_189=222');
    mmTX2.Lines.Add('xCpl_190=Compl Recebedor');
    mmTX2.Lines.Add('xBairro_191=Bairro Recebedor');
    mmTX2.Lines.Add('cMun_192=MARINGA');
    mmTX2.Lines.Add('xMun_193=87023000');
    mmTX2.Lines.Add('CEP_194=87023000');
    mmTX2.Lines.Add('UF_195=PR');
    mmTX2.Lines.Add('cPais_196=1058');//Codigo do pa�s. Utilizar a tabela do BACEN.
    mmTX2.Lines.Add('xPais_197=BRASIL');
    mmTX2.Lines.Add('email_607=testeRecebedor@gmail.com');

   //## dest ## - Informa��es do Destinat�rio do CT-e
////    mmTX2.Lines.Add('CNPJ_199=');//CNPJ destinat�rio PJ
    mmTX2.Lines.Add('CPF_200=50785850015');//CPF destinat�rio PF
////    mmTX2.Lines.Add('IE_201=');//Inscri��o estadual PJ
    mmTX2.Lines.Add('xNome_202=Jo�o Destinaraio Teste');//Raz�o Social ou Nome do remetente
    mmTX2.Lines.Add('fone_203=44999998888');
////    mmTX2.Lines.Add('ISUF_204=');//Obrigat�rio nas opera��es com as �reas com benef�cios de incentivos fiscais sob controle da SUFRAMA

    //## enderDest ## - Endere�o Destinat�rio
    mmTX2.Lines.Add('xLgr_206=Avenida Antonio Carlos');//Logradouro
    mmTX2.Lines.Add('nro_207=2233');//Numero
    mmTX2.Lines.Add('xCpl_208=Sobreloja 1');//Complemento
    mmTX2.Lines.Add('xBairro_209=Centro');//Bairro
    mmTX2.Lines.Add('cMun_210=4115200');//Codigo IBGE do Munic�pio. Informar 9999999 para opera��es com o exterior.
    mmTX2.Lines.Add('xMun_211=MARINGA');//Nome Munic�pio. Informar EXTERIOR para opera��es com o exterior.
    mmTX2.Lines.Add('CEP_212=87023000');
    mmTX2.Lines.Add('UF_213=PR');
    mmTX2.Lines.Add('cPais_214=1058');//Codigo do pa�s. Utilizar a tabela do BACEN.
    mmTX2.Lines.Add('xPais_215=BRASIL');
////    mmTX2.Lines.Add('email_608=');

    //## vPrest ## - Valores da Presta��o de Servi�o
    mmTX2.Lines.Add('vTPrest_228=1');//Valor Total da presta��o do Servi�o
    mmTX2.Lines.Add('vRec_229=1');//Valor a Receber

    //## Comp ## - Componentes do Valor da Presta��o
//    mmTX2.Lines.Add('xNome_231=FRETE VALOR');//Nome do componente. Exemplos: FRETE PESO, FRETE VALOR, SEC/CAT, ADEME, AGENDAMENTO
//    mmTX2.Lines.Add('vComp_232=1.00');//15 posi��es, sendo 13 inteiras e 2 decimais.

    //## imp ## - Informa��es relativas aos Impostos
    //## ICMS ## - Informa��es relativas ao ICMS
    //## ICMS00 ## - Presta��o sujeito � tributa��o normal do ICMS 
    mmTX2.Lines.Add('CST_609=00');//00 � tributa��o normal ICMS  -- Classifica��o tribut�ria do servi�o
    mmTX2.Lines.Add('vBC_610=1.00');//15 posi��es, sendo 13 inteiras e 2 decimais. -- Valor da BC do ICMS
    mmTX2.Lines.Add('pICMS_611=12.00');//5 posi��es, sendo 3 inteiras e 2 decimais. -- Aliquota do ICMS
    mmTX2.Lines.Add('vICMS_612=0.12');//15 posi��es, sendo 13 inteiras e 2 decimais. -- Valor do ICMS

    //## ICMS20 ## - Presta��o sujeito � tributa��o com redu��o de BC do ICMS
    mmTX2.Lines.Add('CST_613=20');//Preencher com: 20 - tributa��o com BC reduzida do ICMS -- Classifica��o tribut�ria do servi�o
    mmTX2.Lines.Add('pRedBC_614=20.00');//5 posi��es, sendo 3 inteiras e 2 decimais. -- Percentual de redu��o da BC
    mmTX2.Lines.Add('vBC_615=1.00');// 15 posi��es, sendo 13 inteiras e 2 decimais. --	Valor da BC do ICMS
    mmTX2.Lines.Add('pICMS_616=10');//5 posi��es, sendo 3 inteiras e 2 decimais. -- Al�quota do ICMS.
    mmTX2.Lines.Add('vICMS_617=0.10');//15 posi��es, sendo 13 inteiras e 2 decimais. -- Valor do ICMS.

    //## ICMS45 ## - ICMS Isento, n�o tributado ou diferido
    mmTX2.Lines.Add('CST_618=41');//Classifica��o Tribut�ria do Servi�o -- 40 � ICMS isen��o; 41 � ICMS n�o tributada; 51 � ICMS diferido;

    //## ICMS60 ## - 	Tributa��o pelo ICMS60 � ICMS cobrado por substitui��o tribut�ria. Responsabilidade do recolhimento do ICMS atribu�do ao tomador ou 3� por ST.
    mmTX2.Lines.Add('CST_619=60');//Classifica��o Tribut�ria do Servi�o -- 60 - ICMS cobrado por substitui��o tribut�ria
    mmTX2.Lines.Add('vBCSTRet_620=1.00');//15 posi��es, sendo 13 inteiras e 2 decimais. -- Valor do frete sobre o qual ser� calculado o ICMS a ser substitu�do na Presta��o.
    mmTX2.Lines.Add('vICMSSTRet_621=0.10');//15 posi��es, sendo 13 inteiras e 2 decimais. -- Resultado da multiplica��o do �vBCSTRet� x �pICMSSTRet� � que ser� valor do ICMS a ser retido pelo Substituto.
                                       //Podendo o valor do ICMS a ser retido efetivamente, sofrer ajustes conforme a op��o tributaria do transportador substitu�do. -- Valor do ICMS ST retido
    mmTX2.Lines.Add('pICMSSTRet_622=10.00');////5 posi��es, sendo 3 inteiras e 2 decimais. -- Percentual de Al�quota incidente na presta��o de servi�o de transporte.
////    mmTX2.Lines.Add('vCred_623=');//15 posi��es, sendo 13 inteiras e 2 decimais. -- Valor do Cr�dito outorgado/ Presumido.
                                  //Preencher somente quando o transportador substitu�do, for optante pelo cr�dito outorgado previsto no Conv�nio 106/96 e corresponde ao
                                  //percentual de 20% do valor do ICMS ST retido.

    //## ICMS90 ## - Icms outros
    mmTX2.Lines.Add('CST_624=90');//Classifica��o tribut�ria do servi�o - 90 � ICMS outros
////    mmTX2.Lines.Add('pRedBC_625=');//Percentual de redu��o da BC. - 5 posi��es, sendo 3 inteiras e 2 decimais.
    mmTX2.Lines.Add('vBC_626=1.00');//Valor da BC do ICMS. - 15 posi��es, sendo 13 inteiras e 2 decimais.
    mmTX2.Lines.Add('pICMS_627=10.00');//Al�quota do ICMS. - 5 posi��es, sendo 3 inteiras e 2 decimais.
    mmTX2.Lines.Add('VICMS_628=0.10');//Valor do ICMS - 15 posi��es, sendo 13 inteiras e 2 decimais.
    mmTX2.Lines.Add('vCred_629=');//Valor do Cr�dito outorgado/ Presumido - 15 posi��es, sendo 13 inteiras e 2 decimais.
    
    //## ICMSOutraUF ## - ICMS devido � UF de origem da presta��o, quando diferente da UF do emitente
    mmTX2.Lines.Add('CST_630=90');//Classifica��o Tribut�ria do Servi�o - 90 - ICMS Outra UF
////    mmTX2.Lines.Add('pRedBCOutraUF_631=');//Percentual de redu��o da BC - 5 posi��es, sendo 3 inteiras e 2 decimais.
    mmTX2.Lines.Add('vBCOutraUF_632=1.00');//Valor da BC do ICMS - 15 posi��es, sendo 13 inteiras e 2 decimais.
    mmTX2.Lines.Add('pICMSOutraUF_633=10.00');//Al�quota do ICMS - 5 posi��es, sendo 3 inteiras e 2 decimais.
    mmTX2.Lines.Add('vICMSOutraUF_634=0.10');//	Valor do ICMS devido outra UF - 15 posi��es, sendo 13 inteiras e 2 decimais.

    //## ICMSSN ## - Simples nacional
    mmTX2.Lines.Add('CST_1409=90');//Classifica��o Tribut�ria do Servi�o - 90 - ICMS Simples Nacional
    mmTX2.Lines.Add('indSN_635=1');//Indica se o contribuinte � Simples Nacional - 1=Sim
////    mmTX2.Lines.Add('infAdFisco_267=');//	Informa��es adicionais de interesse do Fisco - Norma referenciada, informa��es complementares, etc
////    mmTX2.Lines.Add('vTotTrib_268=');//Valor Total dos Tributos - 15 posi��es, sendo 13 inteiras e 2 decimais.

    //## ICMSUFFim ## - Grupo a ser informado nas presta��es de servi�o de transporte interestaduais para consumidor final, n�o contribuinte do ICMS
////    mmTX2.Lines.Add('vBCUFFim_676=');//Valor da Base de C�clculo do ICMS na UF de t�rmino da presta��o do servi�o de transporte - 15 posi��es, sendo 13 inteiras e 2 decimais
////    mmTX2.Lines.Add('pFCPUFFim_682=');//Percentual de ICMS correspondente ao Fundo de Combate � pobreza na UF de t�rmino da presta��o de servi�o de transporte - 5 posi��es, sendo 3 inteiras e 2 decimais.
////    mmTX2.Lines.Add('pICMSUFFim_677=');//Al�quota interna da UF de t�rmino da presta��o do servi�o de transporte - 5 posi��es, sendo 3 inteiras e 2 decimais.
////    mmTX2.Lines.Add('pICMSInter_678=');//Al�quota interestadual das UF envolvidas - 5 posi��es, sendo 3 inteiras e 2 decimais.
////    mmTX2.Lines.Add('vFCPUFFim_683=');//Valor de ICMS correspondente ao Fundo de Combate � pobreza na UF de t�rmino da presta��o - 15 posi��es, sendo 13 inteiras e 2 decimais.
////    mmTX2.Lines.Add('vICMSUFFim_680=');//Valor do ICMS de partilha para a UF de t�rmino da presta��o do servi�o de transporte - 15 posi��es, sendo 13 inteiras e 2 decimais.
    mmTX2.Lines.Add('vICMSUFIni_681=');//Valor do ICMS de partilha para a UF de in�cio da presta��o do servi�o de transporte - 	15 posi��es, sendo 13 inteiras e 2 decimais.

    //## InfCTeNorm ## -	Grupo de informa��es do CT-e Normal e substituto.
    //## infCarga ## - Informa��es da Carga do CT-e
    if cbTipoTransp.ItemIndex <> 4 then //Dever ser informado para todos os modais, com exce��o para o Dutovi�rio.
       mmTX2.Lines.Add('vCarga_671=10.00');//Valor total da carga - 15 posi��es, sendo 13 inteiras e 2 decimais.
    mmTX2.Lines.Add('proPred_271=PRODUTO TESTE');//Informar a descri��o do produto predominante
    mmTX2.Lines.Add('xOutCat_272=GRANEL');//Outras caracter�sticas da carga -  Preencher com: "FRIA", "GRANEL", "REFRIGERADA", "Medidas: 12X12X12"

//    APENAS AERO
    //## infQ ## - 	Informa��es de quantidades da Carga do CT-e
    //    Para o AEREO � obrigat�rio o
    //    preenchimento desse campo da
    //    seguinte forma.
    //    1 - Peso Bruto, sempre em
    //    quilogramas (obrigat�rio);
    //    2 - Peso Cubado; sempre em
    //    quilogramas;
    //    3 - Quantidade de volumes, sempre em
    //    unidades (obrigat�rio);
    //    4 - Cubagem, sempre em metros
    //    c�bicos (obrigat�rio apenas quando for
    //    imposs�vel preencher as dimens�es
    //    da(s) embalagem(ens) na tag xDime do
    //    leiaute do A�reo).
//    mmTX2.Lines.Add('cUnid_274=01');//C�digo da Unidade de Medida - 00-M3; 01-KG; 02-TON; 03-UNIDADE; 04-LITROS; 05-MMBTU;
//    mmTX2.Lines.Add('tpMed_275=PESO BRUTO');//Tipo da Medida - PESO BRUTO, PESO DECLARADO, PESO CUBADO, PESO AFORADO, PESO AFERIDO, PESO BASE DE C�LCULO, LITRAGEM, CAIXAS e etc
//    mmTX2.Lines.Add('qCarga_276=5.4400');//Quantidade - 15 posi��es, sendo 11 inteiras e 4 decimais.
//    mmTX2.Lines.Add('vCargaAverb_1567=12.00');//Valor da Carga para efeito de averba��o - 15 posi��es, sendo 13 inteiras e 2 decimais.
                                              //Normalmente igual ao valor declarado da mercadoria, diferente por exemplo, quando a mercadoria transportada �
                                              //isenta de tributos nacionais para exporta��o, onde � preciso averbar um valor maior, pois no caso de indeniza��o, o valor a ser pago ser� maior

                                              
    //## infDoc ## - 	Informa��es dos documentos transportados pelo CT-e Opcional para Redespacho Intermediario e Servi�o vinculado a multimodal
    //                Poder� n�o ser informado para os CT-e de redespacho intermedi�rio. Nos demais casos dever� sempre ser informado.

    //## infNF ## - Informa��es das NF - Este grupo deve ser informado quando o documento origin�rio for NF
//    mmTX2.Lines.Add('nRoma_130=');//N�mero do Romaneio da NF
//    mmTX2.Lines.Add('nPed_131=');//N�mero do Pedido da NF
//    mmTX2.Lines.Add('mod_605=');//Modelo da Nota Fiscal - Preencher com: 01 - NF Modelo 01/1A e Avulsa; 04 - NF de Produtor;
//    mmTX2.Lines.Add('serie_132=');//S�rie
//    mmTX2.Lines.Add('nDoc_133=');//N�mero
//    mmTX2.Lines.Add('dEmi_134=');//Data de Emiss�o - Formato AAAA-MM-DD
//    mmTX2.Lines.Add('vBC_135=');//Valor da Base de c�lculo do ICMS - 15 posi��es, sendo 13 inteiras e 2 decimais.
//    mmTX2.Lines.Add('vICMS_136=');//Valor total do ICMS - 15 posi��es, sendo 13 inteiras e 2 decimais.
//    mmTX2.Lines.Add('vBCST_137=');//Valor da Base de C�lculo do ICMS ST - 15 posi��es, sendo 13 inteiras e 2 decimais.
//    mmTX2.Lines.Add('vST_138=');//Valor Total do ICMS ST - 15 posi��es, sendo 13 inteiras e 2 decimais.
//    mmTX2.Lines.Add('vProd_139=');//Valor Total dos Produtos - 15 posi��es, sendo 13 inteiras e 2 decimais.
//    mmTX2.Lines.Add('vNF_140=');//Valor Total da NF - 15 posi��es, sendo 13 inteiras e 2 decimais.
//    mmTX2.Lines.Add('nCFOP_141=');//Cfop predominante - CFOP da NF ou, na exist�ncia de mais de um, predomin�ncia pelo crit�rio de valor econ�mico.
//    mmTX2.Lines.Add('nPeso_142=');//Peso total em Kg - 15 posi��es, sendo 13 inteiras e 2 decimais.
//    mmTX2.Lines.Add('PIN_143=');//Pin suframa - PIN atribu�do pela SUFRAMA para a opera��o.
//    mmTX2.Lines.Add('dPrev_144=');//Data prevista de entrega - Formato AAAA-MM-DD

    //## infUnidCarga ## - Informa��es das Unidades de Carga (Containeres/ULD/Outros) - Dispositivo de carga utilizada (Unit Load Device - ULD) significa todo tipo de cont�iner de carga, vag�o, cont�iner
    //                     de avi�o, palete de aeronave com rede ou palete de aeronave com rede sobre um iglu.
//    mmTX2.Lines.Add('tpUnidCarga_705=1');//Tipo da Unidade de Carga - 1 - Container; 2 - ULD; 3 - Pallet; 4 - Outros;
//    mmTX2.Lines.Add('idUnidCarga_706=1010');//Identifica��o da Unidade de Carga - Informar a identifica��o da unidade de carga, por exemplo: n�mero do container.

    //## lacUnidCarga ## - Lacres das Unidades de Carga
//    mmTX2.Lines.Add('nLacre_708=11112222');//N�mero do lacre
//    mmTX2.Lines.Add('qtdRat_707=10.00');//Quantidade rateada (Peso,Volume) - 5 posi��es, sendo 3 inteiras e 2 decimais.

    //## infUnidTransp ## - Informa��es das Unidades de Transporte - Deve ser preenchido com as informa��es das unidades de transporte utilizadas.
//    mmTX2.Lines.Add('tpUnidTransp_701=' + IntToStr(cbTipoUnidade.ItemIndex + 1));//Tipo da unidade de Transporte
//    mmTX2.Lines.Add('idUnidTransp_702=' + edtIDUnidade.Text);//Identifica��o da Unidade de Transporte - 	Informar a identifica��o conforme o tipo de unidade de transporte.
                                                               //Por exemplo: para rodovi�rio tra��o ou reboque dever� preencher com a placa do ve�culo.

    //## lacUnidTransp ## - Lacres das Unidades de Transporte
//    mmTX2.Lines.Add('nLacre_704=124567');//N�mero do lacre

    //## infUnidCarga ## - Informa��es das Unidades de Carga (Containeres/ULD/Outros) - Dispositivo de carga utilizada (Unit Load Device - ULD) significa todo tipo de cont�iner de carga, vag�o, cont�iner
    //                     de avi�o, palete de aeronave com rede ou palete de aeronave com rede sobre um iglu.
////    mmTX2.Lines.Add('tpUnidCarga_709=');//Tipo da Unidade de Carga - 1 - Container; 2 - ULD; 3 - Pallet; 4 - Outros;
////    mmTX2.Lines.Add('idUnidCarga_710=');//Identifica��o da Unidade de Carga - Informar a identifica��o da unidade de carga, por exemplo: n�mero do container.

    //## lacUnidCarga ## - Lacres das Unidades de Carga
////    mmTX2.Lines.Add('nLacre_712=');//N�mero do lacre
////    mmTX2.Lines.Add('qtdRat_711=');//Quantidade rateada (Peso,Volume) - 5 posi��es, sendo 3 inteiras e 2 decimais.
////    mmTX2.Lines.Add('qtdRat_703=');//Quantidade rateada (Peso,Volume) - 5 posi��es, sendo 3 inteiras e 2 decimais.

    //## infNFe ## -
//    mmTX2.Lines.Add('chave_156=1111111111111111111111111111111111');//Chave de acesso da NF-e
//    mmTX2.Lines.Add('PIN_157=2365A5847');//PIN SUFRAMA - 	PIN atribu�do pela SUFRAMA para a opera��o.
////    mmTX2.Lines.Add('dPrev_750=');//Data prevista de entrega - Formato AAAA-MM-DD

    //## infUnidCarga ## - Informa��es das Unidades de Carga (Containeres/ULD/Outros) - Dispositivo de carga utilizada (Unit Load Device - ULD) significa todo tipo de cont�iner de carga, vag�o, cont�iner
    //                     de avi�o, palete de aeronave com rede ou palete de aeronave com rede sobre um iglu.
////    mmTX2.Lines.Add('tpUnidCarga_759=');//Tipo da Unidade de Carga - 1 - Container; 2 - ULD; 3 - Pallet; 4 - Outros;
////    mmTX2.Lines.Add('idUnidCarga_760=');//Identifica��o da Unidade de Carga - Informar a identifica��o da unidade de carga, por exemplo: n�mero do container.

    //## lacUnidCarga ## - Lacres das Unidades de Carga
////    mmTX2.Lines.Add('nLacre_762=');//N�mero do lacre
////    mmTX2.Lines.Add('qtdRat_761=');//Quantidade rateada (Peso,Volume) - 5 posi��es, sendo 3 inteiras e 2 decimais.

    //## infUnidTransp ## - Informa��es das Unidades de Transporte
////    mmTX2.Lines.Add('tpUnidTransp_751=');//Tipo da unidade de Transporte - 1 - Rodovi�rio Tra��o; 2 - Rodovi�rio Reboque; 3 - Navio; 4 - Balsa; 5 - Aeronave; 6 - Vag�o; 7 - Outros
////    mmTX2.Lines.Add('idUnidTransp_752=');//Identifica��o da Unidade de Transporte - Informar a identifica��o conforme o tipo de unidade de transporte. Por exemplo: para rodovi�rio tra��o ou reboque dever� preencher com a placa do ve�culo.

    //## lacUnidTransp ## - Lacres das Unidades de Transporte
////    mmTX2.Lines.Add('nLacre_754=');//N�mero do lacre

    //## infUnidCarga ## - Informa��es das Unidades de Carga (Containeres/ULD/Outros) - Dispositivo de carga utilizada (Unit Load Device - ULD) significa todo tipo de cont�iner de carga, vag�o, cont�iner
    //                     de avi�o, palete de aeronave com rede ou palete de aeronave com rede sobre um iglu.
////    mmTX2.Lines.Add('tpUnidCarga_755=');//Tipo da Unidade de Carga - 1 - Container; 2 - ULD; 3 - Pallet; 4 - Outros;
////    mmTX2.Lines.Add('idUnidCarga_756=');//Identifica��o da Unidade de Carga - Informar a identifica��o da unidade de carga, por exemplo: n�mero do container.

    //## lacUnidCarga ## - Lacres das Unidades de Carga
////    mmTX2.Lines.Add('nLacre_758=');//N�mero do lacre
////    mmTX2.Lines.Add('qtdRat_757=');//Quantidade rateada (Peso,Volume) - 5 posi��es, sendo 3 inteiras e 2 decimais.
////    mmTX2.Lines.Add('qtdRat_753=');//Quantidade rateada (Peso,Volume) - 5 posi��es, sendo 3 inteiras e 2 decimais.

    //## infOutros ## - Informa��es dos demais documentos
//    mmTX2.Lines.Add('tpDoc_159=99');//Tipo de documento origin�rio - 00 - Declara��o; 10 - Dutovi�rio; 59 - CF-e SAT; 65 - NFC-e; 99 - Outros;
//    mmTX2.Lines.Add('descOutros_160=1111111111111111111111111111111111');//Descri��o do documento - Informar descri��o em caso de 99 � Outros. No caso de NFC-e informar a chave de acesso.
////    mmTX2.Lines.Add('nDoc_161=');//N�mero
////    mmTX2.Lines.Add('dEmi_162=');//Data de Emiss�o - Formato AAAA-MM-DD
////    mmTX2.Lines.Add('vDocFisc_163=');//Valor do documento - 15 posi��es, sendo 13 inteiras e 2 decimais.
////    mmTX2.Lines.Add('dPrev_801=');//Data prevista de entrega - Formato AAAA-MM-DD

    //## infUnidCarga ## - Informa��es das Unidades de Carga (Containeres/ULD/Outros) - Dispositivo de carga utilizada (Unit Load Device - ULD) significa todo tipo de cont�iner de carga, vag�o, cont�iner
    //                     de avi�o, palete de aeronave com rede ou palete de aeronave com rede sobre um iglu.
////    mmTX2.Lines.Add('tpUnidCarga_810=');//Tipo da Unidade de Carga - 1 - Container; 2 - ULD; 3 - Pallet; 4 - Outros;
////    mmTX2.Lines.Add('idUnidCarga_811=');//Identifica��o da Unidade de Carga - Informar a identifica��o da unidade de carga, por exemplo: n�mero do container.

    //## lacUnidCarga ## - Lacres das Unidades de Carga
////    mmTX2.Lines.Add('nLacre_813=');//N�mero do lacre
////    mmTX2.Lines.Add('qtdRat_812=');//Quantidade rateada (Peso,Volume) - 5 posi��es, sendo 3 inteiras e 2 decimais.

    //## infUnidTransp ## - Informa��es das Unidades de Transporte
////    mmTX2.Lines.Add('tpUnidTransp_802=');//Tipo da unidade de Transporte - 1 - Rodovi�rio Tra��o; 2 - Rodovi�rio Reboque; 3 - Navio; 4 - Balsa; 5 - Aeronave; 6 - Vag�o; 7 - Outros
////    mmTX2.Lines.Add('idUnidTransp_803=');//Identifica��o da Unidade de Transporte - Informar a identifica��o conforme o tipo de unidade de transporte. Por exemplo: para rodovi�rio tra��o ou reboque dever� preencher com a placa do ve�culo.

    //## lacUnidTransp ## - Lacres das Unidades de Transporte
////    mmTX2.Lines.Add('nLacre_805=');//N�mero do lacre

    //## infUnidCarga ## - Informa��es das Unidades de Carga (Containeres/ULD/Outros) - Dispositivo de carga utilizada (Unit Load Device - ULD) significa todo tipo de cont�iner de carga, vag�o, cont�iner
    //                     de avi�o, palete de aeronave com rede ou palete de aeronave com rede sobre um iglu.
////    mmTX2.Lines.Add('tpUnidCarga_806=');//Tipo da Unidade de Carga - 1 - Container; 2 - ULD; 3 - Pallet; 4 - Outros;
////    mmTX2.Lines.Add('idUnidCarga_807=');//Identifica��o da Unidade de Carga - Informar a identifica��o da unidade de carga, por exemplo: n�mero do container.

    //## lacUnidCarga ## - Lacres das Unidades de Carga
////    mmTX2.Lines.Add('nLacre_809=');//N�mero do lacre
////    mmTX2.Lines.Add('qtdRat_808=');//Quantidade rateada (Peso,Volume) - 5 posi��es, sendo 3 inteiras e 2 decimais.
////    mmTX2.Lines.Add('qtdRat_804=');//Quantidade rateada (Peso,Volume) - 5 posi��es, sendo 3 inteiras e 2 decimais.

    //## docAnt ## - Documentos de Transporte Anterior
      //## emiDocAnt ## - Emissor do documento anterior
  ////    mmTX2.Lines.Add('CNPJ_284=96620146000109');//N�mero do CNPJ - Em caso de empresa n�o estabelecida no Brasil, ser� informado o CNPJ com zeros. Informar os zeros n�o significativos.
  ////    mmTX2.Lines.Add('CPF_285=');//N�mero do CPF - Informar os zeros n�o significativos.
  ////    mmTX2.Lines.Add('IE_286=1489803905');
  ////    mmTX2.Lines.Add('UF_287=PR');//Informar EX para opera��es com o exterior.
  ////    mmTX2.Lines.Add('xNome_288=TESTE EXPEDIDOR');

      //## emiDocAnt ## - Informa��es de identifica��o dos documentos de Transporte Anterior
  //## idDocAntPap ## - Documentos de transporte anterior em papel
  ////    mmTX2.Lines.Add('tpDoc_291=');//Preencher com: 07-ATRE; 08-DTA (Despacho de Transito Aduaneiro); 09-Conhecimento A�reo Internacional; 10 � Conhecimento - Carta de Porte Internacional; 11 � Conhecimento Avulso; 12-TIF (Transporte Internacional Ferrovi�rio); 13-BL (Bill of Lading)
  ////    mmTX2.Lines.Add('serie_292=');//Serie do Documento Fiscal
  ////    mmTX2.Lines.Add('subser_293=');//SubSerie do Documento Fiscal
  ////    mmTX2.Lines.Add('nDoc_294=');//N�mero do Documento Fiscal
  ////    mmTX2.Lines.Add('dEmi_295=');//Data de emiss�o (AAAA-MM-DD)

  //## idDocAntEle ## - Documentos de transporte anterior eletr�nicos
  ////    mmTX2.Lines.Add('chCTe_1410=');//Chave de acesso do CT-e
  
  //## infModal ## - Informa��es do Modal
  ////    mmTX2.Lines.Add('versaoModal_636=');//Vers�o do leiaute epecifico para o Modal

  //## veicNovos ## - Informa��es dos ve�culos transportados
  ////    mmTX2.Lines.Add('chassi_445=');//Chassi do ve�culo
  ////    mmTX2.Lines.Add('cCor_446=');//Cor do ve�culo (c�digo de cada montadora)
  ////    mmTX2.Lines.Add('xCor_447=');//Descri��o da cor
  ////    mmTX2.Lines.Add('cMod_448=');//C�digo marca modelo (utilizar tabela RENAVAM)
  ////    mmTX2.Lines.Add('vUnit_449=');//Valor Unit�rio do Ve�culo
  ////    mmTX2.Lines.Add('vFrete_450=');//Frete unit�rio

  //## cobr ## - Dados da cobran�a do CT-e
  //## fat ## - 	Dados da fatura
  ////    mmTX2.Lines.Add('nFat_637='); - N�mero da fatura
  ////    mmTX2.Lines.Add('vOrig_638='); - Valor original da fatura
  ////    mmTX2.Lines.Add('vDesc_639='); - Valor do desconto da fatura
  ////    mmTX2.Lines.Add('vLiq_640='); - Valor liquido da fatura

  //## dup ## - 	Dados das duplicatas
  ////    mmTX2.Lines.Add('nDup_641=');//N�mero da duplicata
  ////    mmTX2.Lines.Add('dVenc_642=');//Data de Vencimento da duplicate(AAAA-MM-DD)
  ////    mmTX2.Lines.Add('vDup_643=');//Valor da duplicata - 15 posi��es, sendo 13 inteiras e 2 decimais.

  //## infCteSub ## - Informa��es do CT-e de substitui��o
////    mmTX2.Lines.Add('chCTe_452=');//Chave de acesso do CT-e a ser substitu�do (original)
////    mmTX2.Lines.Add('refCteAnu_1411=');//Chave de acesso do CT-e de Anula��o

  //## tomaICMS ## - Informa��o da NF ou CT emitido pelo tomador
////    mmTX2.Lines.Add('refNFe_454=');//Chave de acesso da NF-e emitida pelo Tomador

  //## refNF ## -	Informa��o da NF ou CT emitido pelo tomador
    mmTX2.Lines.Add('CNPJ_456=78616305000110');//Informar o CNPJ do emitente do Documento Fiscal
////    mmTX2.Lines.Add('CPF_816=');
    mmTX2.Lines.Add('mod_457=57');//Informar o c�digo do modelo do Documento fiscal - C�digo padr�o 57
    mmTX2.Lines.Add('serie_458=0');//Informar a s�rie do documento fiscal (informar zero se inexistente)
////    mmTX2.Lines.Add('subserie_459=');
    mmTX2.Lines.Add('nro_460=111111');//Informar o n�mero do documento fiscal
    mmTX2.Lines.Add('valor_461=1.00');//Informar o valor do documento fiscal - 	15 posi��es, sendo 13 inteiras e 2 decimais
    mmTX2.Lines.Add('dEmi_462=' + FormatDateTime('yyyy-mm',Date));//Informar a data de emiss�o do documento fiscal - Formato YYYY-MM-DD
    mmTX2.Lines.Add('refCte_463=12222222222222222222222222222222222222222222');//Chave de acesso do CT-e emitido pelo tomador - 44 caracteres
////    mmTX2.Lines.Add('indAlteraToma_1412=');//Tag com efeito e utiliza��o aguardando legisla��o, n�o utilizar antes de NT espec�fica tratar desse procedimento

    //## infGlobalizado ## - Informa��es do CT-e Globalizado
////    mmTX2.Lines.Add('xObs_1413=');//Preencher com informa��es adicionais, legisla��o do regime especial, etc

  if cbTipoTransp.ItemIndex = 5 then
  begin
    //## infServVinc ## - Informa��es do Servi�o Vinculado a Multimodal
    //## infCTeMultimodal ## - informa��es do CT-e multimodal vinculado
////    mmTX2.Lines.Add('ChCTeMultimodal_1415=');//Chave de acesso do CT-e Multimodal
  end;

    //## infCteComp ## - Detalhamento do CT-e complementado
    mmTX2.Lines.Add('chCTe_1414=');//Chave do CT-e complementado

    //## infCteAnu ## - Detalhamento do CT-e do tipo Anula��o de Valores
////    mmTX2.Lines.Add('chCte_509=');//Chave de acesso do CT-e original a ser anulado e substitu�do
////    mmTX2.Lines.Add('dEmi_510=');//Data de emiss�o da declara��o do tomador n�o contribuinte do ICMS

    //## autXML ## - Autorizados para download do XML do DF-e
////    mmTX2.Lines.Add('CNPJ_814=');
////    mmTX2.Lines.Add('CPF_815=');

    //## infRespTec ## - 	Informa��es do Respons�vel T�cnico pela emiss�o do DF-e
////    mmTX2.Lines.Add('CNPJ_471=');
////    mmTX2.Lines.Add('xContato_472=');
////    mmTX2.Lines.Add('email_473=');
////    mmTX2.Lines.Add('fone_474=');
////    mmTX2.Lines.Add('idCSRT_475=');
////    mmTX2.Lines.Add('hashCSRT_476=');

  case cbTipoTransp.ItemIndex of
    0://## Modal Rodovi�rio ##
      begin
        //## rodo ##
        mmTX2.Lines.Add('RNTRC_305=12345678');//Registro obrigat�rio do emitente do CT-e junto � ANTT para exercer a atividade de transportador rodovi�rio de cargas por conta de terceiros e mediante remunera��o.

        //## occ ## - Ordens de Coleta associados
//        mmTX2.Lines.Add('serie_312=');
//        mmTX2.Lines.Add('nOcc_313=321654');//N�mero da Ordem de coleta
//        mmTX2.Lines.Add('dEmi_314=' + FormatDateTime('yyyy-mm-dd', Now));//Data de emiss�o da ordem de coleta - Formato AAAA-MM-DD

        //## emiOcc ##
//        mmTX2.Lines.Add('CNPJ_316=34006051000142');//N�mero do CNPJ
//        mmTX2.Lines.Add('cInt_317=1472258354');//C�digo interno de uso da transportadora
//        mmTX2.Lines.Add('IE_318=9094411294');//Inscri��o Estadual
//        mmTX2.Lines.Add('UF_319=PR');//Informar EX para opera��es com o exterior.
//        mmTX2.Lines.Add('fone_320=');
      end;
    1://## Modal A�reo ##
      begin
    //aereo
        mmTX2.Lines.Add('nMinu_357=');
        mmTX2.Lines.Add('nOCA_358=');
        mmTX2.Lines.Add('dPrev_359=');
    //natCarga
        mmTX2.Lines.Add('xDime_1101=');
        mmTX2.Lines.Add('cInfManu_1102=');
    //tarifa
        mmTX2.Lines.Add('CL_364=');
        mmTX2.Lines.Add('cTar_365=');
        mmTX2.Lines.Add('vTar_366=');
    //peri
        mmTX2.Lines.Add('nONU_437=');
        mmTX2.Lines.Add('qTotEmb_1416=');
    //infTotAP
        mmTX2.Lines.Add('qTotProd_441=');
        mmTX2.Lines.Add('uniAP_1417=');
      end;
    2://## Modal Aquavi�rio ##
      begin
    //aquav
        mmTX2.Lines.Add('vPrest_368=');
        mmTX2.Lines.Add('vAFRMM_369=');
        mmTX2.Lines.Add('xNavio_372=');
    //balsa
        mmTX2.Lines.Add('xBalsa_1201=');
        mmTX2.Lines.Add('nViag_373=');
        mmTX2.Lines.Add('direc_374=');
        mmTX2.Lines.Add('tpNav_378=');
        mmTX2.Lines.Add('irin_379=');
    //detCont
        mmTX2.Lines.Add('nCont_1202=');
    //Lacre
        mmTX2.Lines.Add('nLacre_381=');
    //infDoc
    //infNF
        mmTX2.Lines.Add('serie_1203=');
        mmTX2.Lines.Add('nDoc_1204=');
        mmTX2.Lines.Add('unidRat_1205=');
    //infNFe
        mmTX2.Lines.Add('chave_1206=');
        mmTX2.Lines.Add('unidRat_1207=');
      end;
    3://## Modal Ferrovi�rio ##
      begin
    //Ferrov
        mmTX2.Lines.Add('tpTraf_383=');
    //trafMut
        mmTX2.Lines.Add('respFat_1301=');
        mmTX2.Lines.Add('ferrEmi_1302=');
        mmTX2.Lines.Add('vFrete_386=');
    //chCTeFerroOrigem_1418
    //ferroEnv
        mmTX2.Lines.Add('CNPJ_388=');
        mmTX2.Lines.Add('cInt_389=');
        mmTX2.Lines.Add('IE_390=');
        mmTX2.Lines.Add('xNome_391=');
    //enderFerro
        mmTX2.Lines.Add('xLgr_393=');
        mmTX2.Lines.Add('nro_394=');
        mmTX2.Lines.Add('xCpl_395=');
        mmTX2.Lines.Add('xBairro_396=');
        mmTX2.Lines.Add('cMun_397=');
        mmTX2.Lines.Add('xMun_398=');
        mmTX2.Lines.Add('CEP_399=');
        mmTX2.Lines.Add('UF_400=');
        mmTX2.Lines.Add('fluxo_384=');
      end;
    4://## Modal Dutovi�rio ##
      begin
    //duto
        mmTX2.Lines.Add('vTar_435=');
        mmTX2.Lines.Add('dIni_1401=');
        mmTX2.Lines.Add('dFim_1402=');
      end;
    5://## Multimodal ##
      begin
    //Multimodal
        mmTX2.Lines.Add('COTM_1501=');
        mmTX2.Lines.Add('indNegociavel_1502=');

      //## Seg ## - Informa��es da seguradora
      //## InfSeg ## - Informa��es da seguradora
        mmTX2.Lines.Add('xSeg_1568=SEGURADORA TESTE');//Nome da Seguradora
        mmTX2.Lines.Add('CNPJ_1569=90760265000180');//Obrigat�rio apenas se respons�vel pelo seguro for (2) respons�vel pela contrata��o do transporte - pessoa jur�dica
        mmTX2.Lines.Add('nApol_1570=12211221122145544521');//N�mero da Ap�lice - Obrigat�rio pela lei 11.442/07 (RCTRC)
        mmTX2.Lines.Add('nAver_1571=');//N�mero da Averba��o - 	N�o � obrigat�rio, pois muitas averba��es ocorrem aap�s a emiss�o do CT, mensalmente, por exemplo.
      end;
  end;
    mmTX2.Lines.Add('SALVAR');
end;

procedure TfrmCTePrincipal.sbGerarTX2Click(Sender: TObject);
begin
  try
    mmTX2.Clear;
    PreencherTX2;

    pcProcessos.ActivePage := tsTX2;
  finally
//    vTX2OK := True;
  end;
end;

procedure TfrmCTePrincipal.sbGerarXMLClick(Sender: TObject);
begin
  try
    mmTX2.Lines.SaveToFile(edtArqTX2.Text);
    
    mmXml.Text := vCTe.GerarXMLporTx2(edtArqTX2.Text);

    pcProcessos.ActivePage := tsXML;
  except
    on e : exception do
     showmessage('Ocorreu o seguinte erro: '+ e.message);
  end;

end;

procedure TfrmCTePrincipal.sbAssinarClick(Sender: TObject);
var
  XMLString : string;
begin
  try
    XMLString := mmXml.Text;
    mmXMLAssinado.Text := vCTe.AssinarCT(XMLString);

    pcProcessos.ActivePage := tsXML;
  except
    on e : exception do
     showmessage('Ocorreu o seguinte erro: '+ e.message);
  end;
end;

procedure TfrmCTePrincipal.sbEnviarClick(Sender: TObject);
begin
  try
    mmEnvio.Lines.Clear;
    mmEnvio.Text := vCTe.EnviarCT('1', mmXMLAssinado.Text);

    edtRecibo.Text := vCTe.ExtrairRecibo(mmEnvio.Text);

    pcProcessos.ActivePage := tsEnvio;

    ShowMessage('Envio feito com sucesso, favor executar a consulta!');

    pcProcessos.ActivePage := tsConsulta;
  except
    on e : exception do
     showmessage('Ocorreu o seguinte erro: '+ e.message);
  end;
end;

procedure TfrmCTePrincipal.sbLimparClick(Sender: TObject);
begin
  Limpar;

  CarregarDadosReinf;
end;

procedure TfrmCTePrincipal.Label6Click(Sender: TObject);
begin
  ShellExecute(Application.Handle, 'open', PChar('http://sped.rfb.gov.br/estatico/FE/A52DB11609848FF5D567967207254F89AAFF06/Leiautes%20da%20EFD-Reinf%20v2.0%20-%20Anexo%20I%20-%20Tabelas.pdf'), nil, nil, 0);
end;

procedure TfrmCTePrincipal.sbConsultaLoteClick(Sender: TObject);
begin
  if edtChave.Text <> '' then
  begin
    mmConsulta.text := vCTe.ConsultarCT(edtChave.Text);
    edtProtocolo.Text := vCTe.ExtrairProtocolo(mmConsulta.text);
  end
  else
  begin
    ShowMessage('Favor informar uma chave antes de prosseguir');
    edtChave.SetFocus;
  end;
end;

procedure TfrmCTePrincipal.sbConsultarReciboClick(Sender: TObject);
begin
  if edtRecibo.Text <> '' then
  begin
    mmConsulta.text := vCTe.ConsultarRecibo(edtRecibo.Text);
    edtProtocolo.Text := vCTe.ExtrairProtocolo(mmConsulta.text);
  end
  else
  begin
    ShowMessage('Favor informar um recibo antes de prosseguir');
    edtRecibo.SetFocus;
  end;
end;

procedure TfrmCTePrincipal.GerarTX2Exclusao;
begin
  mmTX2Exclusao.Clear;
  mmTX2Exclusao.Lines.Add('EXCLUIRR1000');
  mmTX2Exclusao.Lines.Add('tpAmb_4='+ IntToStr(cbAmbiente.ItemIndex + 1));//1 - Produ��o; 2 - Produ��o restrita - dados reais;
  mmTX2Exclusao.Lines.Add('procEmi_5=1');//1 - Aplicativo do contribuinte; 2 - Aplicativo governamental
  mmTX2Exclusao.Lines.Add('verProc_6=1.0');//Informar a vers�o do aplicativo emissor do evento
  mmTX2Exclusao.Lines.Add('tpInsc_8=1');//1 - CNPJ; 2 - CPF;
  mmTX2Exclusao.Lines.Add('nrInsc_9=08187168');//Se [tpInsc_8] for igual a [1], deve ser o n�mero BASE (8 digitos) de CNPJ v�lido; Se [tpInsc_8] for igual a [2], deve ser um CPF v�lido;
  mmTX2Exclusao.Lines.Add('iniValid_13=' + FormatDateTime('yyyy-mm',Date));//Deve ser uma data v�lida, igual ou posterior � data inicial de implanta��o da EFD-Reinf, no formato AAAA-MM.
//  mmTX2Exclusao.Lines.Add('fimValid_14=');
  mmTX2Exclusao.Lines.Add('SALVARR1000');

  pcProcessos.ActivePage := tsExclusao;
end;

procedure TfrmCTePrincipal.GerarXMLAssinado;
begin
  try
//    mmXMLExclusao.Text := vReinf.GerarXMLporTx2(mmTX2Exclusao.Text);

//    mmXMLExclusao.Text := vReinf.AssinarEvento(mmXMLExclusao.Text);
  except
    on e : exception do
     showmessage('Ocorreu o seguinte erro: '+ e.message);
  end;
end;

procedure TfrmCTePrincipal.EnviarExclusao;
//var
//  vRetEnvioExclusao: IspdReinfRetEnviarLoteEventos;
begin
  try
//    vRetEnvioExclusao := vReinf.EnviarLoteEventos(mmXMLExclusao.Text);

    mmRetornoExclusao.Lines.Clear;
//    mmRetornoExclusao.Lines.Add('Identificador do Lote: ' + vRetEnvioExclusao.IdLote);
//    mmRetornoExclusao.Lines.Add('Mensagem de Retorno: ' + vRetEnvioExclusao.Mensagem);

//    edtIDLote.Text := vRetEnvioExclusao.IdLote;
    
//    ExecutarConsulta(vReinf.ConsultarLoteEventos(vRetEnvioExclusao.IdLote), '### CONSULTA DE EXCLUS�O POR ID DO LOTE ###');
  except
    on e : exception do
     showmessage('Ocorreu o seguinte erro: '+ e.message);
  end;
end;

procedure TfrmCTePrincipal.sbExcluirClick(Sender: TObject);
begin
  GerarTX2Exclusao;
  GerarXMLAssinado;
  EnviarExclusao;
end;

procedure TfrmCTePrincipal.SpeedButton1Click(Sender: TObject);
begin
//  if Application.MessageBox('Efetuar a limpeza de todo o ambiente de homologa��o no servidor do Reinf?','Stop',mb_yesno + mb_iconquestion) = id_yes then
//  begin
//    sbPreencherCompClick(Owner);
//
//    PreencherTX2;
//
//    sbGerarXMLClick(Owner);
//    sbAssinarClick(Owner);
//    sbEnviarClick(Owner);
//  end;

  vCTe.ImprimirDACTE(mmXMLAssinado.Text, '', '');
end;

procedure TfrmCTePrincipal.SomenteNumero(Sender: TObject; var Key: Char);
begin
   if  not ( Key in ['0'..'9', Chr(8)] ) then
      Key := #0
end;

end.
