object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 623
  ClientWidth = 837
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 0
    Top = 0
    Width = 837
    Height = 49
    Align = alTop
    Caption = ' Server '
    TabOrder = 0
    object btnLoad: TButton
      Left = 8
      Top = 16
      Width = 75
      Height = 25
      Action = actLoad
      TabOrder = 0
    end
    object btnStart: TButton
      Left = 89
      Top = 16
      Width = 75
      Height = 25
      Action = actStart
      TabOrder = 1
    end
    object btnStop: TButton
      Left = 170
      Top = 16
      Width = 75
      Height = 25
      Action = actStop
      TabOrder = 2
    end
  end
  object GroupBox2: TGroupBox
    Left = 0
    Top = 49
    Width = 837
    Height = 48
    Align = alTop
    Caption = ' Viewer '
    TabOrder = 1
    object btnClient: TButton
      Left = 8
      Top = 16
      Width = 75
      Height = 25
      Action = actLoadViewer
      TabOrder = 0
    end
    object Button1: TButton
      Left = 89
      Top = 17
      Width = 75
      Height = 25
      Action = actAddViewer
      TabOrder = 1
    end
    object Button2: TButton
      Left = 170
      Top = 16
      Width = 75
      Height = 25
      Action = actCloseViewer
      TabOrder = 2
    end
  end
  object FlowPanel1: TFlowPanel
    Left = 0
    Top = 97
    Width = 837
    Height = 526
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 2
  end
  object ActionList1: TActionList
    OnUpdate = ActionList1Update
    Left = 296
    Top = 8
    object actStart: TAction
      Caption = 'Start'
      OnExecute = actStartExecute
    end
    object actStop: TAction
      Caption = 'Stop'
      OnExecute = actStopExecute
    end
    object actLoad: TAction
      Caption = 'Load'
      OnExecute = actLoadExecute
    end
    object actLoadViewer: TAction
      Caption = 'Load viewer'
      OnExecute = actLoadViewerExecute
    end
    object actAddViewer: TAction
      Caption = 'Add viewer'
      OnExecute = actAddViewerExecute
    end
    object actCloseViewer: TAction
      Caption = 'Close viewer'
      OnExecute = actCloseViewerExecute
    end
  end
end
