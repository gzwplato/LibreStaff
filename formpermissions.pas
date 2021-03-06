unit FormPermissions;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  ExtCtrls, StdCtrls, DbCtrls, FrameAddDelEdiSavCan, LCLType, DBGrids, sqldb;

type

  { TFrmPermissions }

  TFrmPermissions = class(TForm)
    DBChkAdminControlAccess1: TDBCheckBox;
    DBChkEditEmployee: TDBCheckBox;
    DBChkAddEmployee: TDBCheckBox;
    DBChkDeleteEmployee: TDBCheckBox;
    DBChkAdminControlAccess: TDBCheckBox;
    DBChkShowTabAddress: TDBCheckBox;
    GrdUserGroups: TDBGrid;
    FraAddDelEdiSavCan1: TFraAddDelEdiSavCan;
    LblUserGroups: TLabel;
    LblPermissions: TLabel;
    PagPermissions: TPageControl;
    PanRight: TPanel;
    Panleft: TPanel;
    TabEmployees: TTabSheet;
    TabAdmin: TTabSheet;
    TabTabs: TTabSheet;
    procedure BtnAddClick(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
    procedure BtnDeleteClick(Sender: TObject);
    procedure BtnEditClick(Sender: TObject);
    procedure BtnSaveClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure GrdUserGroupsCellClick(Column: TColumn);
  private
    { private declarations }
    CurrentRec, TotalRecs: Integer;
    procedure UpdateNavRec;
  public
    { public declarations }
  end;

var
  FrmPermissions: TFrmPermissions;

resourcestring
  Add_IptBox_Caption= 'Add User Group';
  Add_IptBox_Prompt= 'Name:';
  Edit_IptBox_Caption= 'Edit User Group';
  Edit_IptBox_Prompt= 'Name:';
  No_Edit_SUPERUSER= 'SUPERUSERS cannot be edited.';
  No_Delete_SUPERUSERS_Group= 'SUPERUSERS group cannot be deleted.';
  Blank_Value= 'Blank not allowed!';
  Of_LblNavRec= 'of';

implementation

{$R *.lfm}

uses
  FormInputBox, FuncData, DataModule, Globals;

{ TFrmPermissions }

procedure TFrmPermissions.UpdateNavRec;
begin
  CurrentRec:= DataMod.QueUsergroups.RecNo;
  FraAddDelEdiSavCan1.LblNavRec.Caption:= IntToStr(CurrentRec) + ' '+ Of_LblNavRec +' '+ IntToStr(TotalRecs);
  DataMod.QueUsergroups.Edit;
end;

procedure TFrmPermissions.BtnCancelClick(Sender: TObject);
begin
	Close;
end;

procedure TFrmPermissions.BtnDeleteClick(Sender: TObject);
var
  FieldValue: String;
begin
  FieldValue:= DataMod.QueUsergroups.FieldByName(GrdUserGroups.Columns[0].FieldName).AsString;
  if (FieldValue= SUPERUSER_GROUP) then
  	begin
    Application.MessageBox(PChar(No_Delete_SUPERUSERS_Group), 'Error!', MB_OK);
    Exit;
    end;
  FuncData.DeleteTableRecord(DataMod.QueUsergroups, True, FieldValue);
  Dec(TotalRecs);
  UpdateNavRec;
end;

procedure TFrmPermissions.BtnEditClick(Sender: TObject);
var
  FieldValue, DefaultValue, ErrorMsg: String;
  Error: Boolean=FALSE;
  Cancel: Boolean=FALSE;
begin
  DefaultValue:= DataMod.QueUsergroups.FieldByName(GrdUserGroups.Columns[0].FieldName).AsString;
  if (DefaultValue= SUPERUSER_GROUP) then
  	begin
    Error:= TRUE;
    ErrorMsg:= No_Edit_SUPERUSER;
    Application.MessageBox(PChar(ErrorMsg), 'Error!', MB_OK);
    Exit;
    end;
	if FrmInputBox.CustomInputBox(Edit_IptBox_Caption, Edit_IptBox_Prompt, DefaultValue, 255, FieldValue)= TRUE then
  	begin
  	if FieldValue='' then
    	begin
	    Error:= TRUE;
  	  ErrorMsg:= Blank_Value;
    	end
    end
	else
  	begin
    Cancel:= True;
		end;
	if (Error= FALSE) AND (Cancel= False) then
		begin
	  SetLength(WriteFields, 1);
		WriteFields[0].FieldName:= 'Name_Usergroup';
  	WriteFields[0].Value:= FieldValue;
		WriteFields[0].DataFormat:= dtString;
	  FuncData.EditTableRecord(DataMod.QueUsergroups, WriteFields);
 		WriteFields:= nil;
		end
	else if (Error= TRUE) then
		begin
		Application.MessageBox(PChar(ErrorMsg), 'Error!', MB_OK);
	  end;
end;

procedure TFrmPermissions.BtnSaveClick(Sender: TObject);
begin
  FuncData.SaveTable(DataMod.QuePermissions);
  FuncData.SaveTable(DataMod.QueUserGroups);
  Close;
end;

procedure TFrmPermissions.FormCreate(Sender: TObject);
begin
	//Grab the total amount of records:
	TotalRecs:= DataMod.QueUsergroups.RecordCount;
	UpdateNavRec;
end;

procedure TFrmPermissions.GrdUserGroupsCellClick(Column: TColumn);
begin
  UpdateNavRec;
end;

procedure TFrmPermissions.BtnAddClick(Sender: TObject);
var
  FieldValue, ErrorMsg: String;
  Error: Boolean=FALSE;
begin
  if FrmInputBox.CustomInputBox(Add_IptBox_Caption, Add_IptBox_Prompt, '', 255, FieldValue)= TRUE then
  	begin
    if FieldValue='' then
   		begin
	    Error:= TRUE;
  	  ErrorMsg:= Blank_Value;
      end;
    if (Error= FALSE) then
	  	begin
      SetLength(WriteFields, 1);
      WriteFields[0].FieldName:= 'Name_Usergroup';
 	 	  WriteFields[0].Value:= FieldValue;
   		WriteFields[0].DataFormat:= dtString;
 			FuncData.AppendTableRecord(DataMod.QueUsergroups, WriteFields);
    	WriteFields:= nil;
      SetLength(WriteFields, 7); //Change here the number if you add or remove permissions
		  WriteFields[0].FieldName:= 'Usergroup_ID';
 	 	  WriteFields[0].Value:= DataMod.QueUsergroups.FieldByName('ID_Usergroup').AsInteger;
   		WriteFields[0].DataFormat:= dtInteger;
 		  WriteFields[1].FieldName:= 'EditEmployee_Permission';
 	 	  WriteFields[1].Value:= TRUE;
   		WriteFields[1].DataFormat:= dtBoolean;
 		  WriteFields[2].FieldName:= 'AddEmployee_Permission';
 	 	  WriteFields[2].Value:= TRUE;
   		WriteFields[2].DataFormat:= dtBoolean;
 		  WriteFields[3].FieldName:= 'DeleteEmployee_Permission';
 	 	  WriteFields[3].Value:= TRUE;
   		WriteFields[3].DataFormat:= dtBoolean;
 		  WriteFields[4].FieldName:= 'ShowTabAddress_Permission';
 	 	  WriteFields[4].Value:= TRUE;
   		WriteFields[4].DataFormat:= dtBoolean;
 		  WriteFields[5].FieldName:= 'AdminControlAccess_Permission';
 	 	  WriteFields[5].Value:= FALSE;
   		WriteFields[5].DataFormat:= dtBoolean;
 		  WriteFields[6].FieldName:= 'AdminDatabase_Permission';
 	 	  WriteFields[6].Value:= FALSE;
   		WriteFields[6].DataFormat:= dtBoolean;
 			FuncData.AppendTableRecord(DataMod.QuePermissions, WriteFields);
      WriteFields:= nil;
		  Inc(TotalRecs);
 			UpdateNavRec;
  		end
		else
			begin
			Application.MessageBox(PChar(ErrorMsg), 'Error!', MB_OK);
    	end;
    end;
end;

end.

