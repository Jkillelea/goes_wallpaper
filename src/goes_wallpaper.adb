with Ada.Text_IO; use Ada.Text_IO;
with Ada.Direct_IO;
with Ada.Exceptions;
with Ada.Streams;
with AWS.Client;
with AWS.Response;

----------------------------------------------
--  Get an image from GOES-18 (GOES-West)   --
--  To run: SOCKET=openssl alr run          --
----------------------------------------------
procedure Goes_Wallpaper is
    Connection : AWS.Client.HTTP_Connection;
    Noaa_Url   : constant String :=
        "https://cdn.star.nesdis.noaa.gov/GOES18/"
            & "ABI/SECTOR/psw/GEOCOLOR/latest.jpg";

    Image_Data : AWS.Response.Data;

    --  This is probably totally wrong but it works well
    --  for now. You shouldn't have to create a new IO package
    --  for stream elements. You should be able to just write
    --  stream elements to a stream and have it 'just work'
    package Image_IO is new Ada.Direct_IO (Ada.Streams.Stream_Element);
    Image_File : Image_IO.File_Type;

begin
    Put_Line ("Getting " & Noaa_Url);

    AWS.Client.Create (Connection, Noaa_Url);
    AWS.Client.Get (Connection, Image_Data);
    AWS.Client.Close (Connection);

    Image_IO.Create (Image_File, Image_IO.Out_File, "./latest.jpg");

    declare
        Image_Data_Elements : constant Ada.Streams.Stream_Element_Array
            := AWS.Response.Message_Body (Image_Data);
    begin
        for Part of Image_Data_Elements loop
            Image_IO.Write (Image_File, Part);
        end loop;
    end;

    Image_IO.Close (Image_File);
exception
    when E : others =>
        Put_Line (Ada.Exceptions.Exception_Information (E));

        if Image_IO.Is_Open (Image_File) then
            Image_IO.Close (Image_File);
        end if;
end Goes_Wallpaper;
