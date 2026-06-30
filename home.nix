{ inputs, username, ... }:
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";

    extraSpecialArgs = {
      inherit inputs username;
    };

    users.${username} = import ./home/aqua;
  };
}
