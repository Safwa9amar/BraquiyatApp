object DM: TDM
  OnCreate = DataModuleCreate
  Height = 400
  Width = 600
  object Conn: TADOConnection
    LoginPrompt = False
    Mode = cmReadWrite
    Left = 40
    Top = 40
  end
  object qBraquiya: TADOQuery
    Connection = Conn
    Left = 160
    Top = 40
  end
  object qJiha: TADOQuery
    Connection = Conn
    Left = 280
    Top = 40
  end
  object qEmploye: TADOQuery
    Connection = Conn
    Left = 400
    Top = 40
  end
  object qOrient: TADOQuery
    Connection = Conn
    Left = 520
    Top = 40
  end
  object dsBraquiya: TDataSource
    DataSet = qBraquiya
    Left = 160
    Top = 120
  end
  object dsJiha: TDataSource
    DataSet = qJiha
    Left = 280
    Top = 120
  end
end
