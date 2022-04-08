unit UMyConfig;

interface

uses
  SysUtils, Classes, Windows,
  puer.Json.JsonDataObjects, puer.FileUtils;

const
  PROJECT_NAME                = 'dd-iot';

  SYSTEM_NAME                 = 'DD-IoT';
  SYSTEM_CH_NAME              = '物联感知平台';

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
    RootPath: string;           // dd-iot根目录
    TmpPath: string;            // 临时文件目录
    ConfigPath: string;         // 配置文件目录
    LogPath: string;            // 日志文件目录
    ModelsPath: string;         // 各设备型号的模板目录
    DataPath: string;           // 数据文件目录

    GatewayUpdateUrl: string;   // 网关更新URL

    DDVer: string;

    UpStateUrl: string;
    MySN: string;
    MeterNotAvg: Boolean;       // 计量点计算不使用平均算法，长时间离线后，用量都结算为最近一小时的用量
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

  // 系统名称
  _MyConfig.SystemName := SYSTEM_NAME;

  // 项目名称
  _MyConfig.ProjectName := PROJECT_NAME;

  // 会话错误编码
  _MyConfig.SessionName := _MyConfig.ProjectName;
  _MyConfig.SessionErrorCode := SESSION_ERROR_CODE;

  // 数据库名称
  _MyConfig.DBName := DB_METER;

  aFileVer := GetFileVersionDetails(aModuleFileName);
  _MyConfig.DDVer := 'V' + aFileVer.ProductVersion;

  // 根据项目名称生成其他配置
  _MyConfig.UrlHead       := Format(FMT_URL_HEAD, [_MyConfig.ProjectName]);
  _MyConfig.Dll_Ctrl      := Format(FMT_DLL_CTRL, [_MyConfig.ProjectName]);
  _MyConfig.RestDir_Drive := Format(FMT_REST_DIR_DRIVE, [_MyConfig.ProjectName]);
  _MyConfig.DebugHead     := Format(FMT_DEBUG_HEAD, [_MyConfig.ProjectName]);

  // 各种路径
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
