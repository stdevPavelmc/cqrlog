unit uVersion;

{$mode objfpc}
interface

const
  cVersionBase     = '2.6.0 (101)';

  {$IFDEF LCLGtk2}
  cVERSION    = cVersionBase+' Gtk2';
  {$ENDIF}
   {$IFDEF LCLGtk3}
  cVERSION    = cVersionBase+' Gtk3';
  {$ENDIF}
  {$IFDEF LCLQt5}
  cVERSION    = cVersionBase+' QT5';
  {$ENDIF}

  cMAJOR      = 2;
  cMINOR      = 5;
  cRELEAS     = 2;
  cBUILD      = 1;

  cBUILD_DATE = '2022-06-27';

implementation

end.

