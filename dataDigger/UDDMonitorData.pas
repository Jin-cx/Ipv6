unit UDDMonitorData;

interface

const
  MONITOR_TYPE_COMM_SEND     = 'CommSend';
  MONITOR_TYPE_COMM_RECEIVE  = 'CommReceive';
  MONITOR_TYPE_TOPO_CHANGED  = 'TopoChanged';
  MONITOR_TYPE_MONITOR_STATE = 'MonitorState';

type
  TMonitorData = record
    MonitorType: string;
    MonitorData: string;
    MsgId: Integer;
  end;

implementation

end.
