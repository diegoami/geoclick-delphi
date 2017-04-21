{$O+,A+,W-,R-,Q-,B-,X+,T-,P+,H+,J+,C-}

//--------------- user section ----------------------------

{If you have Standard version of Delphi/CPB comment out this define}
{$DEFINE PRODELPHI}

{If you have Client/Server version of Delphi/CPB uncomment this define}
//{$DEFINE CSDELPHI}

{If you do not want BDE to be used in the program comment out this define}
{$DEFINE USEBDE}

{If you have QuickReport V2 or higher installed uncomment this define}
//{$DEFINE QREP}

//--------------- Dream Company section ----------------------------

{ Comment out this define before release }
//{$DEFINE DEBUG}

{$IFDEF CSDELPHI}
{$DEFINE PRODELPHI}
{$ENDIF}

{$IFDEF BCB}
{$IFDEF VER130}
{$DEFINE D5}
{$ENDIF}
{$ENDIF}

{$IFDEF VER93}
{$DEFINE BCB}
{$DEFINE CPB1}
{$ENDIF}

{$IFNDEF VER80}
 {$IFNDEF VER90}
  {$IFNDEF VER93}
    {$IFDEF VER110}
      {$DEFINE CPB3} { C++ Builder 3.0 or higher}
      {$DEFINE BCB}
    {$ENDIF}
    {$DEFINE D3} { Delphi 3.0 or higher }
  {$ENDIF}
 {$ENDIF}
{$ENDIF}

{$IFDEF VER120}
  {$DEFINE D4}
  {$DEFINE D3}
  {$DEFINE CPB3}
{$ENDIF}

{$IFDEF VER125}
{$DEFINE CPB4}
{$DEFINE D4}
{$DEFINE D3}
{$DEFINE CPB3}
{$DEFINE BCB}
{$ENDIF}

{$IFDEF VER130}
{$DEFINE CPB4}
{$DEFINE D4}
{$DEFINE D3}
{$DEFINE CPB3}
{$DEFINE D5}
{$ENDIF}

{$IFDEF VER140}
{$DEFINE CPB4}
{$DEFINE D4}
{$DEFINE D3}
{$DEFINE CPB3}
{$DEFINE D5}
{$DEFINE D6}
{$ENDIF}

{$IFNDEF D3}
  {$DEFINE USEBDE}
{$ENDIF}

{$IFNDEF PRODELPHI}
 {$UNDEF QREP}
{$ENDIF}

{$IFDEF DEMO}
{$D-,L-,Y-}
{$ENDIF}

{$IFDEF D3}
{$DEFINE SHELLOBJ}
{$ENDIF}

{$DEFINE WIN}

{$IFNDEF WIN}
{$UNDEF SHELLOBJ}
{$ENDIF}

//--------------- new section ----------------------------
{$IFDEF D5}
{$IFNDEF DC_DSGNPKG}
//temporary disabled  {$DEFINE USE_DCDESIGN} {use dcDesign.pas instead dsgnintf.pas}
{$ENDIF}
{$ENDIF}

{$IFDEF PRODELPHI}
  {$DEFINE USEMASKEDIT}  
{$ELSE}
  {$IFDEF BCB}
    {$DEFINE USEMASKEDIT}  
  {$ENDIF}
{$ENDIF}
