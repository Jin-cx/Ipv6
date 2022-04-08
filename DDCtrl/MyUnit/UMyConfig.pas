unit UMyConfig;

interface

uses
  SysUtils, Classes, Windows,
  puer.Json.JsonDataObjects, puer.FileUtils;

const
  PROJECT_NAME                = 'dd-iot';

  SYSTEM_NAME                 = 'DD-IoT';
  SYSTEM_CH_NAME              = '������֪ƽ̨';

  SESSION_ERROR_CODE          = 'SYS002';

  BROKER_CRT_FILE_NAME        = '%s\brokerssl\ddiot.crt';

  DB_METER                    = 'db_DD_Meter';

  FMT_URL_HEAD                = '/%s/do/';
  FMT_DLL_CTRL                = '%s\_do\DDCtrl.dll';
  FMT_REST_DIR_DRIVE          = '%s\_do\rests\drive\';
  FMT_DEBUG_HEAD              = '<%s.ctrl> ';
  FMT_ROOT_PATH               = '%s\';
  FMT_TMP_PATH                = '%s\tmp\';
  FMT_CONFIG_PATH             = '%s\config\';
  FMT_LOG_PATH                = '%s\log\';
  FMT_MODELS_PATH             = '%s\models\';
  FMT_DATA_PATH               = '%s\data\';

type
  TMyConfig = record
    SystemName: string;
    ProjectName: string;
    Dll_Ctrl: string;
    SessionName: string;
    SessionErrorCode: string;
    UrlHead: string;
    DebugHead: string;
    RestDir_Drive: string;
    DBName: string;
    BrokerCrt: string;
    RootPath: string;           // dd-iot��Ŀ¼
    TmpPath: string;            // ��ʱ�ļ�Ŀ¼
    ConfigPath: string;         // �����ļ�Ŀ¼
    LogPath: string;            // ��־�ļ�Ŀ¼
    ModelsPath: string;         // ���豸�ͺŵ�ģ��Ŀ¼
    DataPath: string;           // �����ļ�Ŀ¼

    GatewayUpdateUrl: string;   // ���ظ���URL

    DDVer: string;

    UpStateUrl: string;
    MySN: string;
    MeterNotAvg: Boolean;       // ��������㲻ʹ��ƽ���㷨����ʱ�����ߺ�����������Ϊ���һСʱ������
  end;

var
  _MyConfig: TMyConfig;

procedure doInitConfig(const aModuleFileName: string);

implementation

procedure doInitConfig(const aModuleFileName: string);
var
  aRootDir: string;
  aJson: TJsonObject;
  aFileVer: TFileVersionDetails;
begin
  aRootDir := ExtractFileDir(aModuleFileName);

  // ϵͳ����
  _MyConfig.SystemName := SYSTEM_NAME;

  // ��Ŀ����
  _MyConfig.ProjectName := PROJECT_NAME;

  // �Ự�������
  _MyConfig.SessionName := _MyConfig.ProjectName;
  _MyConfig.SessionErrorCode := SESSION_ERROR_CODE;

  // ���ݿ�����
  _MyConfig.DBName := DB_METER;

  aFileVer := GetFileVersionDetails(aModuleFileName);
  _MyConfig.DDVer := 'V' + aFileVer.ProductVersion;

  // ������Ŀ����������������
  _MyConfig.UrlHead       := Format(FMT_URL_HEAD, [_MyConfig.ProjectName]);
  _MyConfig.Dll_Ctrl      := Format(FMT_DLL_CTRL, [_MyConfig.ProjectName]);
  _MyConfig.RestDir_Drive := Format(FMT_REST_DIR_DRIVE, [_MyConfig.ProjectName]);
  _MyConfig.DebugHead     := Format(FMT_DEBUG_HEAD, [_MyConfig.ProjectName]);

  // ����·��
  _MyConfig.BrokerCrt := Format(BROKER_CRT_FILE_NAME, [aRootDir]);
  _MyConfig.RootPath := Format(FMT_ROOT_PATH, [aRootDir]);
  _MyConfig.TmpPath := Format(FMT_TMP_PATH, [aRootDir]);
  _MyConfig.ConfigPath := Format(FMT_CONFIG_PATH, [aRootDir]);
  _MyConfig.LogPath := Format(FMT_LOG_PATH, [aRootDir]);
  _MyConfig.ModelsPath := Format(FMT_MODELS_PATH, [aRootDir]);
  _MyConfig.DataPath := Format(FMT_DATA_PATH, [aRootDir]);

  //_MyConfig.GatewayUpdateUrl
  aJson := TJsonObject.Create;
  try
    try
      aJson.LoadFromFile(aRootDir + '\Config.cfg');
      _MyConfig.GatewayUpdateUrl := aJson.S['gatewayUpdateUrl'];

      _MyConfig.UpStateUrl := aJson.S['upStateUrl'];
      _MyConfig.MySN := aJson.S['mySN'];
      _MyConfig.MeterNotAvg := aJson.B['meterNotAvg'];
    except
      _MyConfig.GatewayUpdateUrl := '';
    end;
  finally
    aJson.Free;
  end;
end;

end.
