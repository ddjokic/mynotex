// ***********************************************************************
// ***********************************************************************
// MyNotex 1.2
// Author and copyright: Massimo Nardello, Modena (Italy) 2010-2013.
// Free software released under GPL licence vers. 3.

// In this software is used DBZVDateTimePicker component
// (http://wiki.freepascal.org/ZVDateTimeControls_Package#TDBZVDateTimePicker),
// a modified version of RichMemo component
// (http://wiki.lazarus.freepascal.org/RichMemo) and Dcpcrypt
// component (http://wiki.lazarus.freepascal.org/DCPcrypt).
// The source code of the modified version of RichMemo is available in
// the website of MyNotex.

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version. You can read the version 3
// of the Licence in http://www.gnu.org/licenses/gpl-3.0.txt
// or in the file Licence.txt included in the files of the
// source code of this software.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
// ***********************************************************************
// ***********************************************************************

unit Unit3;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Sqlite3DS, DB, FileUtil, LResources, Forms, Controls,
  Graphics, Dialogs, DBCtrls, StdCtrls, DBGrids;

type

  { TfmMoveNote }

  TfmMoveNote = class(TForm)
    bnCloseNote: TButton;
    bnMoveNote: TButton;
    dsMoveSubjects: TDatasource;
    grMoveNotes: TDBGrid;
    lbMoveNoteSub: TLabel;
    sqMoveSubjects: TSqlite3Dataset;
    procedure bnCloseNoteClick(Sender: TObject);
    procedure bnMoveNoteClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  fmMoveNote: TfmMoveNote;

implementation

uses Unit1;

{ TfmMoveNote }

procedure TfmMoveNote.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  // Close the form and the dataset
  sqMoveSubjects.Close;
end;

procedure TfmMoveNote.FormCreate(Sender: TObject);
begin
  //Change form color
  fmMoveNote.Color := fmMain.Color;
end;

procedure TfmMoveNote.bnCloseNoteClick(Sender: TObject);
begin
  // Close form
  Close;
end;

procedure TfmMoveNote.bnMoveNoteClick(Sender: TObject);
var
  AttDir, NtTitle, NtText, NtTags, NtAttName, NTOldUID, NTCheckPwd: string;
  NtDate: TDateTime;
  IDOldNote, IDNewNote, i: integer;
  myStringList: TStringList;
begin
  // Move note
  try
    try
      fmMain.sqNotes.DisableControls;
      with fmMain.sqNotes do
      begin
        // Change the subject of the note
        NtTitle := FieldByName('NotesTitle').AsString;
        NtDate := FieldByName('NotesDate').AsDateTime;
        NtText := FieldByName('NotesText').AsString;
        NtTags := FieldByName('NotesTags').AsString;
        NtAttName := FieldByName('NotesAttName').AsString;
        NTOldUID := FieldByName('NotesUID').AsString;
        IDOldNote := FieldByName('IDNotes').AsInteger;
        NTCheckPwd := FieldByName('NotesCheckPwd').AsString;
        Append;
        FieldByName('ID_Subjects').AsInteger :=
          sqMoveSubjects.FieldByName('IDSubjects').AsInteger;
        FieldByName('NotesTitle').AsString := NtTitle;
        FieldByName('NotesDate').AsDateTime := NtDate;
        FieldByName('NotesTags').AsString := NtTags;
        FieldByName('NotesAttName').AsString := NtAttName;
        FieldByName('NotesCheckPwd').AsString := NTCheckPwd;
        Post;
        ApplyUpdates;
        // Update possibile UID in images tags
        NtText := StringReplace(NtText, '<IMG SRC="' + NTOldUID,
          '<IMG SRC="' + FieldByName('NotesUID').AsString, [rfReplaceAll]);
        Edit;
        FieldByName('NotesText').AsString := NtText;
        Post;
        ApplyUpdates;
        IDNewNote := FieldByName('IDNotes').AsInteger;
        // Rename possibile attachments before deleting note
        if FieldByName('NotesAttName').AsString <> '' then
        begin
          AttDir := ExtractFileNameWithoutExt(fmMain.sqSubjects.FileName);
          if DirectoryExistsUTF8(AttDir) = False then
          begin
            MessageDlg(fmMain.msg030, mtWarning, [mbOK], 0);
            Abort;
          end;
          myStringList := TStringList.Create;
          myStringList.Text := FieldByName('NotesAttName').AsString;
          for i := 0 to myStringList.Count - 1 do
            RenameFileUTF8(AttDir + DirectorySeparator + NTOldUID +
              '-' + ExtractFileNameOnly(myStringList[i]) + '.zip',
              AttDir + DirectorySeparator + fmMain.sqNotes.FieldByName(
              'NotesUID').AsString + '-' + ExtractFileNameOnly(myStringList[i]) + '.zip');
          myStringList.Free;
        end;
        // Rename possibile pictures before deleting note
        AttDir := ExtractFileNameWithoutExt(fmMain.sqSubjects.FileName);
        if DirectoryExistsUTF8(AttDir) = True then
        begin
          i := 0;
          while FileExistsUTF8(AttDir + DirectorySeparator + NTOldUID +
              '-img' + FormatFloat('0000', i) + '.jpeg') = True do
          begin
            RenameFileUTF8(AttDir + DirectorySeparator + NTOldUID +
              '-img' + FormatFloat('0000', i) + '.jpeg',
              AttDir + DirectorySeparator +
              fmMain.sqNotes.FieldByName('NotesUID').AsString +
              '-img' + FormatFloat('0000', i) + '.jpeg');
            Inc(i);
          end;
        end;
        Locate('IDNotes', IDOldNote, []);
        Delete;
        ApplyUpdates;
      end;
      fmMain.sqSubjects.Locate('IDSubjects',
        sqMoveSubjects.FieldByName('IDSubjects').AsString, []);
      fmMain.sqNotes.Locate('IDNotes', IDNewNote, []);
      Close;
    finally
      fmMain.sqNotes.EnableControls;
    end;
  except
    MessageDlg(fmMain.msg027, mtWarning, [mbOK], 0);
    Close;
  end;
end;

initialization
  {$I unit3.lrs}

end.
