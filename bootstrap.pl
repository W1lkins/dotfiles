#!/usr/bin/perl

use warnings;
use Term::ANSIColor qw(:constants);
use File::Compare;
use File::Spec;

sub info {
  print YELLOW, "[ ... ] @_\n";
}

sub user {
  print WHITE, "[ ??? ] @_\n";
}

sub success {
  print GREEN "[  ✔  ] @_\n";
}

sub fail {
  print RED "[ FAIL ] @_\n";
  exit 1
}

sub get_os {
  my $my_os = `uname -s`;
  chomp $my_os;
  return $my_os;
}


sub setup_gitconfig {
  my $file = $ENV{"HOME"}."/.gitconfig";

  # check if gitconfig already exists
  if (! -f $file) {
    info("setting up gitconfig");

    $os = get_os();

    my $credential = ($os eq "Darwin") ? "osxkeychain" : "cache";

    user("what is your github author name?");
    my $name = <STDIN>;
    chomp $name;

    user("what is your github author email?");
    my $email = <STDIN>;
    chomp $email;

    # grab the file
    my $copy_gitconfig = system("cp git/gitconfig $file");
    open(FILE, "<$file") || die "gitconfig not found\n";
    my @lines = <FILE>;
    close(FILE);

    # overwrite placeholders with our information
    foreach (@lines) {
      $_ =~ s/AUTHORNAME/$name/g;
      $_ =~ s/AUTHOREMAIL/$email/g;
      $_ =~ s/GIT_CREDENTIAL_HELPER/$credential/g;
    }

    # rewrite the file
    open(FILE, ">$file") || die "gitconfig not found\n";
    print FILE @lines;
    close(FILE);

    success("gitconfig created");
  } else {
    success("skipped gitconfig");
  }
}

sub link_file {
  my ($file, $dest) = @_;
  my $full = File::Spec->rel2abs($file);
  my $overwrite = 0;
  my $backup = 0;
  my $skip = 0;
  my $action = 0;

  # check if the file exists, or its a dir, or its a symlink
  if (-f $dest || -d $dest || -l $dest) {
    if ($overwrite == 0 && $backup == 0 && $skip == 0) {
      # if the destnation exists and is already a symlink, skip it
      if (-e $dest && -l $dest) {
        $skip = 1;
      } else {
        # if a file exists, and is not a symlink
        user("file already exists: $dest, what do you want to do?");
        user("[s]kip, [o]verwrite, [b]ackup?");
        my $option = <STDIN>;
        chomp $option;

        # figure out what to do from user input
        $overwrite = 1 if $option eq "o";
        $backup = 1 if $option eq "b";
        $skip = 1 if $option eq "s";
      }
    }

    if ($overwrite) {
      unlink $dest;
      success("removed $dest");
    }

    if ($backup) {
      rename $dest, $dest.".backup";
      success("moved $dest to $dest.backup");
    }

    if ($skip) {
      success("skipped $file");
    }
  }

  if (!$skip) {
    # finally symlink the files
    my $symlink = symlink($full, $dest);
    if ($symlink) {
      success("linked $file to $dest");
    }
  }
}

sub install_dotfiles {
  info("installing dotfiles");
  my $overwrite_all = 0;
  my $backup_all = 0;
  my $skip_all = 0;

  # find all the .sym files in the cwd
  opendir(DIR, ".");
  @files = grep (/\.sym$/, readdir(DIR));
  closedir(DIR);

  foreach my $file (@files) {
    my $dest = $ENV{"HOME"}."/.$file";
    # remove .sym from the end of the path
    $dest =~ s/(.+)\.[^.]+$/$1/;
    link_file($file, $dest);
  }
}

sub install_vim_submodules {
  # if we have submodule updates to do, do them now
  chdir("vim.sym") or die "$!\n";
  system("git submodule init");
  info("updating git submodules");
  my $sub_up = system("git submodule update");
  if ($sub_up == 0) {
    success("finished installing git submodules");
  } else {
    fail("failed installing git submodules");
  }
}

sub attempt_setup_osx {
  user("do you want to install brew & OSX dependencies? Your password will be needed (Y/n)");
  my $resp = lc <STDIN>;
  chomp $resp;

  if (lc $resp eq "y" || $resp eq "") {
    info("installing dependencies");
    my $osx_init = system("source macos/osx-init > /tmp/osx-install.log 2>&1");
    if ($osx_init == 0) {
      success("dependencies installed");
    } else {
      fail("error installing dependencies");
    }
  } else {
    info("not installing dependencies");
  }
}

setup_gitconfig();
install_dotfiles();
install_vim_submodules();

$os = get_os();
if ($os eq "Darwin") {
  attempt_setup_osx();
}

success("all installed");