_: {
  programs.librewolf.profiles.default.search = {
    enable = true;
    force = true;
    default = "ddg";
    privateDefault = "ddg";
    engines = {
      "Nix Packages" = {
        urls = [
          { template = "https://search.nixos.org/packages?channel=unstable&query={searchTerms}"; }
        ];
        icon = "https://nixos.org/favicon.png";
        definedAliases = [ "@np" ];
      };

      google.metaData.hidden = true;
      bing.metaData.hidden = true;
      ebay.metaData.hidden = true;
    };
  };
}
