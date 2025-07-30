{
  pkgs,
  lib,
  ...
}: let
  inherit (lib) pipe recursiveUpdate;

  hashedPassword = "$6$T3eCnq9giW$vjBlWEh9w/nJ7lV9/6hyYUX1P7YmP70Ajo1w47rsLM0q356FHWDG8c4NDQZMrF06uXDlQ.C/L5zUb9fUvJzNh/";

  sshKeys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCogRPMTKyOIQcbS/DqbYijPrreltBHf5ctqFOVAlehvpj8enEE51VSjj4Xs/JEsPWpOJL7Ldp6lDNgFzyuL2AOUWE7wlHx2HrfeCOVkPEzC3uL4OjRTCdsNoleM3Ny2/Qxb0eX2SPoSsEGvpwvTMfUapEa1Ak7Gf39voTYOucoM/lIB/P7MKYkEYiaYaZBcTwjxZa3E+v7At4umSZzv8x24NV60fAyyYmt5hVZRYgoMW+nTU4J/Oq9JGgY7o+WPsOWcgFoSretRnGDwjM1IAUFVpI45rQH2HTKNJ6Bp6ncKwtVaP2dvPdBFe3x2LLEhmh1jDwmbtSXfoVZxbONtub2i/D8DuDhLUNBx/ROgal7N2RgYPcPuNdzfp8hMPjPGZVcSmszC/J1Gz5LqLfWbKKKti4NiSX+euy+aYlgW8zQlUS7aGxzRC/JSgk2KJynFEKJjhj7L9KzsE8ysIgggxYdk18ozDxz2FMPMV5PD1+8x4anWyfda6WR8CXfHlshTwhe+BkgSbsYNe6wZRDGqL2no/PY+GTYRNLgzN721Nv99htIccJoOxeTcs329CppqRNFeDeJkGOnJGc41ze+eVNUkYxOP0O+pNwT7zNDKwRwBnT44F0nNwRByzj2z8i6/deNPmu2sd9IZie8KCygqFiqZ8LjlWTD6JAXPKtTo5GHNQ== yk"

    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC538FOusIV3UgbXukgtamrb7d6cCwVVczlXhxuqOT9HBasuydkYIyYD10bJogTUmW9BeuzAZRysmEMbG1stEEx178cIeBeAGx/H3DdA4kRJUUdRCx17KMcXUz2eSeToygM5pgQL0XqDqGIwOOlwNtfm2KOMS8oJtaKNu2WXLhmGN69OxslgtKMQG3HB0tdUMha2R2rKbQ2nNad6ldAlp+cwBIursJKtYZ7cCavMQG2ocxvd+dRKpbvPF2zwAegR8ysOBJizCVJq8aKyPRhnOrWvpeKTqU+miK9q/kZ/4s7cmkKGPnG/AWhZ2GRITm9NjuOJBA7sXwBOG6u+XXaJbLHqgV/zLiz7qSmeCOTtDRjZId98fZ4AMURNrj/74OsYi8PnHm1crpSjI7BJPEWwiJ/DaxptKOs7wpsbSqW+lzfhFw92tPDhK6AnOkUjVuW02gJSXcVjh5NkbWVC2Koy7rorNdpqCWlIVpDFW6LoECRfaLdEjXRbxxWvGwiQOn/jHbZoXaBQLMuXyMwRiLYt6LhuFHkS0E1d2Bikgx8DxaE33yJaMPaWlqlg6Dl28wKp1ZXxhflSzVs7D9CwqILrR7yiBTnSAO7IZ/JBFoVzcMXl3Y68n7Q3wf4D7+Ph9LJl/jQHZm/fC/tMIdWgmpyCC2gQ/ztDW2jOTlFwEymgrLd9w== io"

    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCvxgZYpPD7scfXbD+kM+NXvxf4vQR7DA2VccvyL6SWeqsPBxGUQPb/XbVm0rSwU5SuaqvVG3BV6LjumZbV6JcZkniD30qT/GSzF2yxtuGd+0Ee6zyyosAZ3r3V0yPqsLdj1nzoKFZBQpDGdq9upVpO6ZJ2MAKDZFanEqcMdk9oXh9WL4zzUkeGEB4OSbBYDF7nhq8s3ncNS4AXlGpc8MrSDVj0IQrW2j6ugTMx78lXCyejuIknR9A1Etamm8xIcuIxsRToqFYrar97hDxAUGTclGDMyug/43TZPH0woJPbXPgyN45o8VaiJIMuVMyaUUZj6QjdXe/U2SqpAQu1fxgeYMJGqaUqtegBh0tCgwpHce3/CBFIGpAjM8W1srhX6t/+R6BK+a9FPUm/z7zsAdIS9IurRpqWMjY82bUid82PXKLRrYwMZrkh7vJTcUUzjfs7X8fhpfGfquqP9v4nsFrAcchzjYcBuoxT8trFTU1/9J1d2UvdvcZr/LHUEe1cADDDaSbUw5JvJc70B1georwFzNS1vqh4Y2pwWupXZ0nsRgrPygnZ3wknn/jCzArXUYUX4Lm1sMBMATWzYbu8AD7yCxosLniIHFksIWvmdsGk3QRw0XVisaN5qBwLMdHOIOKFfELdL32cS1f/y/fb9CMUN2oOD+otFvny4ALvghnZ+w== os"
  ];

  mkUser = user: {
    ${user} = {
      inherit hashedPassword;
      isNormalUser = true;
      extraGroups = ["docker" "lxd" "networkmanager" "scanner" "lp" "wheel" "vboxusers" "libvirtd" "plugdev"];
      openssh.authorizedKeys.keys = sshKeys;
      shell = pkgs.bash;
    };
  };
in {
  users.mutableUsers = false;

  users.users = pipe {} [
    (recursiveUpdate (mkUser "jlotoski"))
    (recursiveUpdate (mkUser "backup"))
    (recursiveUpdate {
      builder = {
        isSystemUser = true;
        createHome = false;
        uid = 500;
        openssh.authorizedKeys.keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAbUsp9OrrYHpi1Wb0AQxbkw2ePEkIW2PrYEDY3pvgkZ builder"];
        group = "builder";
        useDefaultShell = true;
      };
    })
  ];

  users.groups.builder.gid = 500;

  security.sudo.wheelNeedsPassword = true;
  users.groups.plugdev = {members = ["jlotoski" "backup"];};
}
