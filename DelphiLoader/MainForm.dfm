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
    object Label1: TLabel
      Left = 431
      Top = 21
      Width = 32
      Height = 13
      Caption = 'proxy:'
    end
    object Label2: TLabel
      Left = 599
      Top = 21
      Width = 15
      Height = 13
      Caption = 'ID:'
    end
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
    object Button3: TButton
      Left = 304
      Top = 16
      Width = 121
      Height = 25
      Caption = 'Connect to repeater'
      TabOrder = 3
      OnClick = Button3Click
    end
    object Edit1: TEdit
      Left = 469
      Top = 18
      Width = 121
      Height = 21
      TabOrder = 4
      Text = 'localhost'
    end
    object edtIDServer: TEdit
      Left = 620
      Top = 18
      Width = 77
      Height = 21
      TabOrder = 5
      Text = '1234'
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
    object Label3: TLabel
      Left = 431
      Top = 21
      Width = 32
      Height = 13
      Caption = 'proxy:'
    end
    object Label4: TLabel
      Left = 599
      Top = 21
      Width = 15
      Height = 13
      Caption = 'ID:'
    end
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
    object Button4: TButton
      Left = 304
      Top = 17
      Width = 121
      Height = 25
      Caption = 'Viewer via repeater'
      TabOrder = 3
      OnClick = Button4Click
    end
    object edtProxyClient: TEdit
      Left = 469
      Top = 18
      Width = 121
      Height = 21
      TabOrder = 4
      Text = 'localhost'
    end
    object edtClientID: TEdit
      Left = 620
      Top = 18
      Width = 77
      Height = 21
      TabOrder = 5
      Text = '1234'
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
  object tmrRepeaterCheck: TTimer
    Enabled = False
    OnTimer = tmrRepeaterCheckTimer
    Left = 504
    Top = 48
  end
end
