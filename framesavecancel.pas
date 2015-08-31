unit FrameSaveCancel;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, ExtCtrls, Buttons;

type

  { TFraSaveCancel }

  TFraSaveCancel = class(TFrame)
    BtnCancel: TBitBtn;
    BtnSave: TBitBtn;
    PanSaveCancel: TPanel;
  private
    { private declarations }
  public
    { public declarations }
  protected
           procedure Loaded; override;
  end;

implementation

{$R *.lfm}

uses
  FormMain;

procedure TFraSaveCancel.Loaded;
begin
  inherited;
  FrmMain.ImgLstBtn.GetBitmap(3, BtnSave.Glyph);
end;

end.

