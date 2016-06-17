object frmAbout: TfrmAbout
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'About PNG Veil'
  ClientHeight = 270
  ClientWidth = 517
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 261
    Height = 13
    Caption = 'PNG Veil 2.0 - Copyright (C) 2016 Bernard Ford '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label2: TLabel
    Left = 10
    Top = 239
    Width = 97
    Height = 13
    Cursor = crHandPoint
    Caption = 'nextrandom.com'
    Color = clBtnFace
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold, fsUnderline]
    ParentColor = False
    ParentFont = False
    OnClick = Label2Click
    OnMouseDown = Label2MouseDown
    OnMouseUp = Label2MouseUp
  end
  object btnOk: TButton
    Left = 434
    Top = 234
    Width = 75
    Height = 25
    Caption = 'Ok'
    ModalResult = 1
    TabOrder = 0
    WordWrap = True
  end
  object RichEdit1: TRichEdit
    Left = 8
    Top = 27
    Width = 501
    Height = 201
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Tahoma'
    Font.Style = []
    Lines.Strings = (
      'The MIT License (MIT)'
      ''
      'Copyright (c) 2016 Bernard Ford'
      ''
      
        'Permission is hereby granted, free of charge, to any person obta' +
        'ining a copy of this '
      
        'software and associated documentation files (the "Software"), to' +
        ' deal in the Software '
      
        'without restriction, including without limitation the rights to ' +
        'use, copy, modify, merge, '
      
        'publish, distribute, sublicense, and/or sell copies of the Softw' +
        'are, and to permit '
      
        'persons to whom the Software is furnished to do so, subject to t' +
        'he following '
      'conditions:'
      ''
      
        'The above copyright notice and this permission notice shall be i' +
        'ncluded in all copies or '
      'substantial portions of the Software.'
      ''
      'THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, '
      
        'EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES ' +
        'OF '
      
        'MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRING' +
        'EMENT. '
      
        'IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR' +
        ' ANY '
      
        'CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTR' +
        'ACT, '
      
        'TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH TH' +
        'E '
      'SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.'
      ''
      
        'DCPCrypt: Copyright David Barton. licensed under the terms of th' +
        'e MIT License'
      ''
      'Application icon: GPL 2.0 provided by '
      
        'https://www.elegantthemes.com/blog/freebie-of-the-week/beautiful' +
        '-flat-icons-for-'
      'free')
    ParentFont = False
    PlainText = True
    ScrollBars = ssVertical
    TabOrder = 1
    Zoom = 100
  end
end
