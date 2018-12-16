{ mkDerivation, Cabal, cabal-install, stdenv, base, mtl
} : mkDerivation {
  pname = "monadtransformers-example";
  version = "0.0.1";
  src = ./.;
  buildTools = [
    cabal-install
  ];
  setupHaskellDepends = [ base Cabal ];
  libraryHaskellDepends = [
    base mtl
  ];
  testHaskellDepends = [
    base
  ];
  homepage = "https://github.com/kendricktan/monadtransformers-example";
  description = "MonadTransformers Example";
  license = stdenv.lib.licenses.mit;
}
