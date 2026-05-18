# Core Flake

The central repository for tools, utilities, and NixOS modules provided by **SnapSettle**. 

Instead of managing multiple individual repository URLs in your system configuration, you can use this umbrella flake to automatically gain access to all SnapSettle projects.

## Included Projects

* **dashnix** (NixOS Module)
* **nix-helpers** (NixOS Module & Package)
* **gitgetter** (NixOS Module & Package)

## Getting Started

### 1. Add to your Flake Inputs

Add this repository to your system's `flake.nix` inputs:

```nix
inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  
  # Add the SnapSettle core flake
  core.url = "github:snapsettle/core";
};

```

### 2. Enable the NixOS Modules

You can either enable **all** SnapSettle modules at once using the `.default` module, or pick and choose individual ones.

#### Option A: Enable everything automatically (Recommended)

```nix
outputs = { nixpkgs, core, ... }: {
  nixosConfigurations.mySystem = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      core.nixosModules.default # Dynamically imports all available modules
      ./configuration.nix
    ];
  };
};

```

#### Option B: Enable specific modules manually

```nix
outputs = { nixpkgs, core, ... }: {
  nixosConfigurations.mySystem = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      core.nixosModules.dashnix
      core.nixosModules.gitgetter
      ./configuration.nix
    ];
  };
};

```

## Using Packages Directly

If you want to use the CLI tools without enabling their respective NixOS configuration modules, you can access them directly.

### Install in your system configuration

```nix
{ pkgs, inputs, ... }: {
  environment.systemPackages = [
    inputs.core.packages.${pkgs.system}.gitgetter
    inputs.core.packages.${pkgs.system}.nix-helpers
  ];
}

```

### Run on-the-fly (Ad-hoc)

You can run tools immediately using `nix run` without installing them permanently:

```bash
nix run github:snapsettle/core#gitgetter -- --help

```

## Development

This repository uses `treefmt` to maintain consistent code styling. If you are contributing, you can format the code automatically before committing by running:

```bash
nix fmt

```