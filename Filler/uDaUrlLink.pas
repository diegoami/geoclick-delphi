unit uDaUrlLink;

interface

type
  TLocationType = (LOCAL, TOBROWSER, TOFRAME);

  TDAURLLink = class
    URL : String;
    Title : String;
    Description : String;
    LocationType : TLocationType;
    RealPath : String;
  end;

implementation

end.
 