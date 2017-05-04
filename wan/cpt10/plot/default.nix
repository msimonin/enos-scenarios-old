with import <nixpkgs> {}; {
  pyEnv = stdenv.mkDerivation {
    name = "py";
    buildInputs = [ stdenv python27Full python27Packages.virtualenv python27Packages.ipython
    python27Packages.matplotlib python27Packages.numpy python27Packages.requests ];
    shellHook = ''
      # SetUp the virtual environment
      if [ ! -d venv ]
      then
        virtualenv --python=python2.7 venv
        source venv/bin/activate
        pip install requests_file objectpath
      fi

      source venv/bin/activate
    '';
  };
}
