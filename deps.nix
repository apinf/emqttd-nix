{ stdenv, fetchFromGitHub, buildRebar3, buildErlangMk, buildMix, fetchHex, buildHex }:

let rebarScript = ./rebar-delete-deps.erl.script;
    addScript = origfile: script: ''
      test -f ${origfile}.script &&\
        mv ${origfile}.script ${origfile}.script.old
      cp ${script} ${origfile}.script
    '';
    addRebarScript = addScript "./rebar.config";
    removeRebarDeps = ''
      ${addRebarScript rebarScript}
      rm -f rebar.lock
    '';
    copyFolder = libdir: dir: ''
      cp -Hrt $out/lib/erlang/lib/${libdir} ${dir}
    '';
    deps = self: {
      "bcrypt" = buildRebar3 rec {
        name = "bcrypt";
        version = "a63df34d4957dbb70a703c67c75ed9fee2c78971";
        src = fetchFromGitHub {
          owner = "smarkets";
          repo="erlang-bcrypt";
          rev = "a63df34d4957dbb70a703c67c75ed9fee2c78971";
          sha256 = "0nayyrb6g2zqdzs742yrs9wwv9yncg83dnsrgnq3b0xq1mqidif6";
        };
        beamDeps = [ ];
        compilePorts = true;
      };
      "clique" = buildRebar3 rec {
        name = "clique";
        version = "50a13f3a6424b4261cf67ba2d5b8e0baf6eacb79";
        src = fetchFromGitHub {
          owner = "emqtt";
          repo="clique";
          rev = "50a13f3a6424b4261cf67ba2d5b8e0baf6eacb79";
          sha256 = "0xxa5j8g7smhr1qrig2yw6hjhxp745skh5dznfph9gkcrjzdlisr";
        };
        beamDeps = with self; [ cuttlefish ];
        patchPhase = removeRebarDeps;
      };
      "cuttlefish" = buildErlangMk rec {
        name ="cuttlefish";
        version = "26989cf390dc33a924eeecc448623aed748a3798";
        src = fetchFromGitHub {
          owner = "emqtt";
          repo="cuttlefish";
          rev = "26989cf390dc33a924eeecc448623aed748a3798";
          sha256 = "09k0ljqad4hz7gnndkry2f2ffc5asnvdrvsch5qih9xzzm5k6zbw";
        };
        beamDeps = with self; [ getopt lager neotoma ];
        patches = [ ./cuttlefish-remove-vsn-git.patch ];
        prePatch = removeRebarDeps;
      };
      "ecpool" = buildRebar3 rec {
        name = "ecpool";
        version = "c637a98ab62808b4886ecf35c98346eae44cb918";
        src = fetchFromGitHub {
          owner = "emqtt";
          repo="ecpool";
          rev = "c637a98ab62808b4886ecf35c98346eae44cb918";
          sha256 = "1psar05jn69pm3988hlqdwpc4aa0qp9vzmsf0dmgbbqdgvp45vqh";
        };
        beamDeps = with self; [ gproc ];
        patchPhase = removeRebarDeps;
      };
      "ekka" = buildErlangMk rec {
        name = "ekka";
        version = "900762a3d13cf54c74e1b9aa4ffba874b4cd77c6";
        src = fetchFromGitHub {
          owner = "emqtt";
          repo="ekka";
          rev = "900762a3d13cf54c74e1b9aa4ffba874b4cd77c6";
          sha256 = "12zc3n5r4888b4vpwiiq7gb57ywqnpvf1kqgy73sbmfykyqqgai5";
        };
        beamDeps = with self; [ jsx lager cuttlefish ];
      };
      "emq_auth_pgsql" = buildErlangMk rec {
        name = "emq_auth_pgsql";
        version = "0900921e8be7b4b9ba73efeee76b7fd377915254";
        src = fetchFromGitHub {
          owner = "emqtt";
          repo="emq-auth-pgsql";
          rev = "0900921e8be7b4b9ba73efeee76b7fd377915254";
          sha256 = "1pk7s4bqaipcp5axdal3nlc999yjx2ghvca0gs1gk4b2lvw2jp87";
        };
        beamDeps = with self; [epgsql ecpool clique emqttd];
        postInstall = copyFolder name "etc";
      };
      "emq_dashboard" = buildErlangMk rec {
        name = "emq_dashboard";
        version = "5a839f7b61f395a928c2353938bf870cf6955735";
        src = fetchFromGitHub {
          owner = "emqtt";
          repo="emq-dashboard";
          rev = "5a839f7b61f395a928c2353938bf870cf6955735";
          sha256 = "03k5gpql3hr1kzj97m2ayv6bxr5al1y4dczz17c2pz6dnhmgdlpv";
        };
        beamDeps = with self; [emqttd lager cuttlefish];
        postInstall = copyFolder name "etc";
      };
      "emq_plugin_elasticsearch" = buildRebar3 rec {
        name = "emq_plugin_elasticsearch";
        version = "e55de8c698258f6abacee026f9cbdfccfece00b9";
        src = fetchFromGitHub {
          owner = "phanimahesh";
          repo="emq_plugin_elasticsearch";
          rev = "e55de8c698258f6abacee026f9cbdfccfece00b9";
          sha256 = "1a3namzkq5d47hih7rlpi5sqgarfvm7gk3ffpm8mmb0dq4xv578h";
        };
        beamDeps = with self; [ esio uuid emqttd ];
        patchPhase = removeRebarDeps;
        buildPlugins = with self; [ rebar3_cuttlefish ];
        postInstall = copyFolder "${name}-${version}" "etc";
      };
      "rebar3_cuttlefish" = buildRebar3 rec {
        name = "rebar3_cuttlefish";
        version = "0.15.0";
        src = fetchHex {
          pkg = "rebar3_cuttlefish";
          inherit version;
          sha256 = "0jcqrpb8ahigsdmvy9mi3lsz1msid5qqv0jzs3i8q1zf3qrhc98g";
        };
        beamDeps = with self; [ cuttlefish ]; 
        patchPhase = removeRebarDeps;
      };
      "rebar3_neotoma_plugin" = buildRebar3 rec {
        name = "rebar3_neotoma_plugin";
        version = "0.2.0";
        src = fetchHex {
          pkg = name;
          inherit version;
          sha256 = "1f4nfdjmm059x7wzxqnlmd38l255sjdhlcfkqy8aqz01ijqbvsy0";
        };
        beamDeps = with self; [neotoma];
        patchPhase = removeRebarDeps;
      };
      "emqttd" = buildErlangMk rec {
        name = "emqttd";
        version = "419004a37af340ddb22d54cba2aa53d16a5ba746";
        src = fetchFromGitHub {
          owner = "emqtt";
          repo="emqttd";
          rev = "419004a37af340ddb22d54cba2aa53d16a5ba746";
          sha256 = "02s2dmzcwm9ny9nh449mwr7zndp1acs114zaj986ybdxzjqz9s51";
        };
        beamDeps = with self; [goldrush gproc lager esockd ekka mochiweb pbkdf2 lager_syslog bcrypt clique jsx];
        postInstall = copyFolder name "etc";
      };
      "epgsql" = buildRebar3 rec {
       # We are aware of error code generator in makefile
       # however its ressult is committed to the repo,
       # and we prefer deterministic builds.
       # postgres version in deployment will also be locked to prevent surprises.
       # Hence not using buildErlangMk.
        name = "epgsql";
        version = "84b2821b25b63f6153686cbabc7e7ea8374692f5";
        src = fetchFromGitHub {
          owner = "epgsql";
          repo="epgsql";
          rev = "84b2821b25b63f6153686cbabc7e7ea8374692f5";
          sha256 = "1yczf64gy2nkjy8kbxmdzbndvcn4a4hj47z5dm6yfbirqd1vpbrj";
        };
        beamDeps = [];
      };
      "esio" = buildRebar3 rec {
        name = "esio";
        version = "5cb528b60bbb08b4cd5d43a8c36339681968ca0d";
        src = fetchFromGitHub {
          owner = "fogfish";
          repo="esio";
          rev = "5cb528b60bbb08b4cd5d43a8c36339681968ca0d";
          sha256 = "007qcfmg69g2bzdnc19fcacv5g1p8qjcx88nf8kp0vw9f8ai7zky";
        };
        beamDeps = with self; [ knet jsx ];
        patchPhase = removeRebarDeps;
      };
      "knet" = buildRebar3 rec {
        name = "knet";
        version = "98466705f43127418db898f577cbb74b4059f144";
        src= fetchFromGitHub {
          owner = "kfsm";
          repo = "knet";
          rev = "98466705f43127418db898f577cbb74b4059f144";
          sha256 = "0b5s64kf2qp43vsk3vj5zkh36zdsqzpgx0sw5a7ba4rkz36jdpj9";
        };
        beamDeps = with self; [lager feta pns pipe datum htstream];
        patchPhase = removeRebarDeps;
      };
      feta = buildRebar3 rec {
        name = "feta";
        version = "07bb63115de4f2369f54bacc8e7ff10b8f79cc41";
        src = fetchFromGitHub {
          owner = "fogfish";
          repo = "feta";
          rev = "07bb63115de4f2369f54bacc8e7ff10b8f79cc41";
          sha256 = "075jpy33myc4hzjjpxszgqkmrf45s312zcawv8wkxln4vrb3k4zm";
        };
        beamDeps = with self; [];
      };
      pns = buildRebar3 rec {
        name = "pns";
        version = "92bfcf925064227dad32568ec84172e9321ca761";
        src = fetchFromGitHub {
          owner = "fogfish";
          repo = "pns";
          rev = "92bfcf925064227dad32568ec84172e9321ca761";
          sha256 = "067m7wlmy9l5mq5c7imrx779pxv4qr2kml6mbpsbn16nyq4w814m";
        };
        beamDeps = with self; [];
      };
      pipe = buildRebar3 rec {
        name = "pipe";
        version = "a091f919659818cfe37e2d8c5d44d73962322ab9";
        src = fetchFromGitHub {
          owner = "kfsm";
          repo = "pipe";
          rev = "a091f919659818cfe37e2d8c5d44d73962322ab9";
          sha256 = "1k26vw97l3hag8ha53k4lbd8f4dp716lqqkzi5aq9lbvyqqqxp45";
        };
        beamDeps = with self; [];
      };
      datum = buildRebar3 rec {
          name = "datum";
          version = "43cf71a4b93441dae0a3266b690fbe4d2d28ed61";
          src = fetchFromGitHub {
            owner = "fogfish";
            repo = "datum";
            rev = "43cf71a4b93441dae0a3266b690fbe4d2d28ed61";
            sha256 = "1m8ry5v5nlshiki35w36i22kmgndz7zx64kn6mh29kn854rk2mky";
          };
          beamDeps = with self; [];
        };
      htstream = buildRebar3 rec {
        name = "htstream";
        version = "c181c1dc2a43960af3477973eaa33db2def840ec";
        src = fetchFromGitHub {
          owner = "kfsm";
          repo = "htstream";
          rev = "c181c1dc2a43960af3477973eaa33db2def840ec";
          sha256 = "1zxig84n5jv8l18k03ci0a194bsiw5f5hjrg6w235bhqcw5n97q6";
        };
        beamDeps = with self; [];
      };
      "esockd" = buildErlangMk rec {
        name = "esockd";
        version = "17da9488a84fc18787d737a4e1f7406fab800b61";
        src = fetchFromGitHub {
          owner = "emqtt";
          repo="esockd";
          rev = "17da9488a84fc18787d737a4e1f7406fab800b61";
          sha256 = "0fwzkn7dk0wz53c01bpi85hncymf7zqxg4wlpwxi79lmyss859iz";
        };
        # lager is not listed in makefile but this uses lager parse transform
        # better be explicit rather than relying on transitive dep. 
        beamDeps = with self; [gen_logger lager];
      };
      "gen_logger" = buildRebar3 rec {
        name = "gen_logger";
        version = "f6e9f2f373d99f41ffe0579ab5a5f3b19472c9c5";
        src = fetchFromGitHub {
          owner = "emqtt";
          repo="gen_logger";
          rev = "f6e9f2f373d99f41ffe0579ab5a5f3b19472c9c5";
          sha256 = "09r9h7mkibk48gk5wrhvzzbhsk8m9c8azzd6g171djhvs2ls56z6";
        };
        beamDeps = with self; [lager];
        patchPhase = removeRebarDeps;
      };
      "getopt" = buildRebar3 rec {
        name ="getopt";
        version = "388dc95caa7fb97ec7db8cfc39246a36aba61bd8";
        src = fetchFromGitHub {
          owner = "basho";
          repo="getopt";
          rev = "388dc95caa7fb97ec7db8cfc39246a36aba61bd8";
          sha256 = "0rdgcz766sdlmfsygqp1ln21n15359pb8d3s51zsab35xavr92ja";
        };
        beamDeps= [];
      };
      "goldrush" = buildRebar3 rec {
        name ="goldrush";
        version = "8f1b715d36b650ec1e1f5612c00e28af6ab0de82";
        src = fetchFromGitHub {
          owner = "basho";
          repo="goldrush";
          rev = "8f1b715d36b650ec1e1f5612c00e28af6ab0de82";
          sha256 = "0611dgqa7bv9varr2l7whmj6x4x1xa7i544idk6wqaay4hpa7fs7";
        };
        beamDeps = [];
      };
      "gproc" = buildRebar3 rec {
        name = "gproc";
        version = "6a4fff3b8eb14a0b09808579c3f1f87cd153b715";
        src = fetchFromGitHub {
          owner = "uwiger";
          repo="gproc";
          rev = "6a4fff3b8eb14a0b09808579c3f1f87cd153b715";
          sha256 = "1vp05qj4aayvs5vk12rs6qbv9m5fiywkc7vn5q0jfdvvrnc169az";
        };
        # edown is unused in source, needed only to build docs.
        # gen_leader is used only when built with GPROC_DIST=1.
        # This is not the default behaviour, and appears to be uncommon in the wild.
        # Last sections of https://github.com/uwiger/gproc/blob/6a4fff3b8eb14a0b09808579c3f1f87cd153b715/doc/erlang07-wiger.pdf
        # provide some insight.
        beamDeps = with self; [ /* XXX: edown gen_leader */ ];
        patchPhase = removeRebarDeps;
      };
      "jsx" = buildMix rec {
        name = "jsx";
        version = "6a01f3a43b00e45f3fac4016565e35696363cefa";
        src = fetchFromGitHub {
          owner = "talentdeficit";
          repo="jsx";
          rev = "6a01f3a43b00e45f3fac4016565e35696363cefa";
          sha256 = "1pkyvn677sir7rx3z8f7jkjhwswdjrbh28pr0iw97iajydqw1phx";
        };
        beamDeps = [];
      };
      "lager" = buildRebar3 rec {
        name= "lager";
        version = "81eaef0ce98fdbf64ab95665e3bc2ec4b24c7dac";
        src = fetchFromGitHub {
          owner = "basho";
          repo="lager";
          rev = "81eaef0ce98fdbf64ab95665e3bc2ec4b24c7dac";
          sha256 = "14bax07wrvfms4zlhz8ay8565pjji01w7qiq6b93i787a484viph";
        };
        beamDeps = with self; [ goldrush ];
        patchPhase = removeRebarDeps;
      };
      "lager_syslog" = buildRebar3 rec {
        name = "lager_syslog";
        version = "126dd0284fcac9b01613189a82facf8d803411a2";
        src = fetchFromGitHub {
          owner = "basho";
          repo="lager_syslog";
          rev = "126dd0284fcac9b01613189a82facf8d803411a2";
          sha256 = "0ww5ygm0vvcawf1avxpk7a0bc61bzna41y864s33k6f23hsvi02r";
        };
        beamDeps = with self; [lager syslog];
        patchPhase = removeRebarDeps;
      };
      "mochiweb" = buildRebar3 rec{
        name ="mochiweb";
        version = "4d38d8ce0340d1934f422625e7a2cf6de8171231";
        src = fetchFromGitHub {
          owner = "emqtt";
          repo="mochiweb";
          rev = "4d38d8ce0340d1934f422625e7a2cf6de8171231";
          sha256 = "0c2lg6im3ah3wkw9lmn2r9xmrjic0z52bg91734rxqd9sk61ks3c";
        };
        beamDeps = with self; [esockd];
        patchPhase = removeRebarDeps;
      };
      "neotoma" = buildRebar3 rec {
        name = "neotoma";
        version = "6ac6007c7713712a80096de5c7cdf5b85b01374e";
        src = fetchFromGitHub {
          owner = "basho";
          repo="neotoma";
          rev = "6ac6007c7713712a80096de5c7cdf5b85b01374e";
          sha256 = "1fkqjfhvqjkgcfjb9lgiplq42s038vkph0l85bn4jpmh4z0mwz9w";
        };
        beamDeps = [];
      };
      "pbkdf2" = buildRebar3 rec {
        name = "pbkdf2";
        version = "05f8d0c04629ade51dafc26a4b0b1f6bd49970c9";
        src = fetchFromGitHub {
          owner = "emqtt";
          repo="pbkdf2";
          rev = "05f8d0c04629ade51dafc26a4b0b1f6bd49970c9";
          sha256 = "0fdi04ywfkszypcczc1wfb4d9fcihrsvsriirqsqi8cqdn12kdbb";
        };
        beamDeps = [];
      };
      "syslog" = buildRebar3 rec {
        name = "syslog";
        version = "4a6c6f2c996483e86c1320e9553f91d337bcb6aa";
        src = fetchFromGitHub {
          owner = "Vagabond";
          repo="erlang-syslog";
          rev = "4a6c6f2c996483e86c1320e9553f91d337bcb6aa";
          sha256 = "142phqd8ap5kwki9gw6jlas8cagm1pj1zi9qi4cg3gmmv7872rpb";
        };
        beamDeps = [];
        compilePorts = true;
        # For some reason pc complains no so_name or application.
        # app.src exists and should work, but whatever. inject so_name.
        patchPhase = ''
          cat << EOF > rebar.config.script
          lists:keystore(so_name, 1, CONFIG, {so_name, "syslog_drv.so"}).
          EOF
        '';
      };
      "uuid" = buildErlangMk {
        name = "uuid";
        version = "1fdc1b367902da71b774a34ae15690811ac17b99";
        src = fetchFromGitHub {
          owner = "avtobiff";
          repo="erlang-uuid";
          rev = "1fdc1b367902da71b774a34ae15690811ac17b99";
          sha256 = "0n5a6bzdk13rwr4sn1yw9k1p5mdb28cmns6h214p0d86gqw6r8z7";
        };
        beamDeps = [];
      };
    };
in
stdenv.lib.fix deps
