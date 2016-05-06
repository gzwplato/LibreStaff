unit FormLogin;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  DbCtrls, Buttons, ExtCtrls, PopupNotifier, Globals, FuncData, DataModule,
  FormMain, Crypt;

type
  { TFrmLogin }
  TFrmLogin = class(TForm)
    BtnEnter: TBitBtn;
    BtnExit: TBitBtn;
    EdiUser: TEdit;
    EdiPassword: TEdit;
    ImgUser: TImage;
    ImgPassword: TImage;
    Img22: TImageList;
    LblPassword: TLabel;
    LblUser: TLabel;
    LblLibreStaff: TLabel;
    procedure BtnEnterClick(Sender: TObject);
    procedure EdiPasswordKeyPress(Sender: TObject; var Key: char);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  FrmLogin: TFrmLogin;
  PopLogin: TPopupNotifier;

resourcestring
  lg_UserNotExistsTitle= 'Error!';
  lg_UserNotExistsText= 'Username does not exist.';
  lg_PasswordDoesNotMatchTitle= 'Error!';
  lg_PasswordDoesNotMatchText= 'Password does not match.';

implementation

{$R *.lfm}

{ TFrmLogin }

procedure TFrmLogin.FormCreate(Sender: TObject);
begin
  //Get bitmaps
  Img22.GetBitmap(0, ImgUser.Picture.Bitmap);
	Img22.GetBitmap(1, ImgPassword.Picture.Bitmap);
  Img22.GetBitmap(2, BtnEnter.Glyph);
  Img22.GetBitmap(3, BtnExit.Glyph);
  //Set lenght for the input boxes
  EdiUser.MaxLength:= USERNAME_LENGTH;
  EdiPassword.MaxLength:= PASSWORD_LENGTH;
  FuncData.ExecSQL(DataMod.QueUsers, SELECT_ALL_USERS_SQL); //Open User's table
end;

procedure TFrmLogin.FormShow(Sender: TObject);
begin
	//Remember the username?
  RememberUsername:= StrToBool(INIFile.ReadString('Access Control','RememberUsername','False'));
  if (RememberUsername= TRUE) then
  	begin
    Username:= INIFile.ReadString('Access Control','Username','');
    if Not(Username= '') then
      begin
      EdiUser.Text:= Username;
      EdiPassword.SetFocus;
      end;
    end;
end;

procedure TFrmLogin.BtnEnterClick(Sender: TObject);
var
  LoginUser, LoginPassword, HashLoginPassword, HashUser, SaltUser: String;
begin
  LoginUser:= EdiUser.Text;
  LoginPassword:= EdiPassword.Text;
  PopLogin:= TCustomPopupNotifier.Create(2);
  //Search the user name, password and salt
  FuncData.ExecSQL(DataMod.QueVirtual, 'SELECT ID_User, Hash_User, Salt_User FROM Users WHERE Name_User='''+LoginUser+''' LIMIT 1');
  if (DataMod.QueVirtual.IsEmpty= FALSE) then
    begin
    SaltUser:= DataMod.QueVirtual.FieldByName('Salt_User').AsString;
    HashLoginPassword:= Crypt.HashString(SaltUser+LoginPassword);
    HashUser:= DataMod.QueVirtual.FieldByName('Hash_User').AsString;
    if (HashLoginPassword= HashUser) then
      begin
      if (RememberUsername= TRUE) then
        begin
	      INIFile.WriteString('Access Control', 'Username', QuotedStr(LoginUser));
        end;
      ModalResult:= mrOK;
      end
    else
    	begin
      PopLogin.Title:= lg_PasswordDoesNotMatchTitle;
  	  PopLogin.Text:= lg_PasswordDoesNotMatchText;
			PopLogin.ShowAtPos(Left+EdiPassword.Left, Top+EdiPassword.Top);
      end;
    end
  else
    begin
		PopLogin.Title:= lg_UserNotExistsTitle;
		PopLogin.Text:= lg_UserNotExistsText;
		PopLogin.ShowAtPos(Left+EdiUser.Left, Top+EdiUser.Top);
    end;
  //Get the user
end;

procedure TFrmLogin.EdiPasswordKeyPress(Sender: TObject; var Key: char);
begin
	if (Key= #13) then
    begin
    BtnEnter.Click;
    end
end;

end.


