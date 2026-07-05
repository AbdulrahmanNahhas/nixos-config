{ ... }:
{
  programs.firefox.profiles.aqua.search = {
    force = true;
    default = "ddg";
    engines = {
      "Nix Packages" = {
        urls = [
          { template = "https://search.nixos.org/packages?channel=unstable&query={searchTerms}"; }
        ];
        icon = "https://nixos.org/favicon.png";
        definedAliases = [ "@np" ];
      };
      "bing".metaData.hidden = true;
      "ebay".metaData.hidden = true;
    };
  };
}
