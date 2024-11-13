inputs: {config, lib, pkgs, ...}:
let 
  cfg = config.textfox;
  inherit (pkgs.stdenv.hostPlatform) system;
  package = inputs.self.packages.${system}.default;
in {

  imports = [
    inputs.nur.hmModules.nur
  ];

  options.textfox = {
    enable = lib.mkEnableOption "Enable textfox";
    profile = lib.mkOption {
      type = lib.types.str;
      description = "The profile to apply the textfox configuration to";
    };
    fontFamily = lib.mkOption {
      type = lib.types.str;
      default = "\"SF Mono\", Consolas, monospace";
      description = "The font family to use";
    };
    fontSize = lib.mkOption {
      type = lib.types.str;
      default = "14px";
      description = "The font family to use";
    };
    # TODO: make these configurable
    # --tf-accent: var(--toolbarbutton-icon-fill);
    # --tf-bg: var(--lwt-accent-color, -moz-dialog);
    # --tf-border: var(--toolbar-field-background-color);
    # --tf-border-transition: 0.2s ease;
    # --tf-rounding: 0px;
    # --tf-margin: 0.8rem;
    # --tf-width: 2px;
    displayHorizontalTabs = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enables horizontal tabs at the top";
    };
    enableSidebery = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable sidebery extension";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.firefox = {
      enable = true;
      profiles."${cfg.profile}" = {
          extraConfig = builtins.readFile "${package}/user.js";
          extensions = if cfg.enableSidebery then [ config.nur.repos.rycee.firefox-addons.sidebery ] else [ ];
      };
    };

    home.file.".mozilla/firefox/${cfg.profile}/chrome" = {
        source = "${package}/chrome";
        recursive = true;
    };
    home.file.".mozilla/firefox/${cfg.profile}/chrome/config.css" = {
      text = lib.strings.concatStrings [
        ":root {"
        ( lib.strings.concatStrings [ " --tf-font-family: " cfg.fontFamily ";" ] )
        ( lib.strings.concatStrings [ " --tf-font-size: " cfg.fontSize ";" ] )
        ( lib.strings.concatStrings [ " --tf-display-horizontal-tabs: " ( if cfg.displayHorizontalTabs then "block" else "none" ) ";" ] )
        " }"
      ];
    };
  };
}
