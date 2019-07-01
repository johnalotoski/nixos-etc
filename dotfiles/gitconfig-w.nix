''
[include]
  path = .gitconfig.local

[user]
  name = John Lotoski
  email = john.lotoski@iohk.io
  signingkey = 23807F69494663D6

[commit]
  gpgsign = true

[gpg]
  program = gpg

[github]
  user = johnalotoski

[color]
  ui = true

[color "branch"]
  current = yellow reverse
  local = yellow
  remote = green

[color "diff"]
  meta = yellow bold
  frag = magenta bold
  old = red bold
  new = green bold

[alias]

  # Add
  a = add                           # add
  chunkyadd = add --patch           # stage commits chunk by chunk

  # Branch
  b = branch -v                     # branch (verbose)

  # Commit
  c = commit -m                     # commit with message
  ca = commit -am                   # commit all with message
  ci = commit                       # commit
  amend = commit --amend            # ammend your last commit
  ammend = commit --amend           # ammend your last commit

  # Checkout
  co = checkout                     # checkout
  nb = checkout -b                  # create and switch to a new branch (mnemonic: "git new branch branchname...")

  # Cherry-pick
  cp = cherry-pick -x               # grab a change from a branch

  # Diff
  d = diff                          # diff unstaged changes
  dc = diff --cached                # diff staged changes
  last = diff HEAD^                 # diff last committed change

  # Log
  lo = log -10 --oneline
  los = log -3 --show-signature
  l = log --graph --date=short
  changes = log --pretty=format:\"%h %cr %cn %Cgreen%s%Creset\" --name-status
  short = log --pretty=format:\"%h %cr %cn %Cgreen%s%Creset\"
  changelog = log --pretty=format:\" * %s\"
  shortnocolor = log --pretty=format:\"%h %cr %cn %s\"
  hist = log --pretty=format:\"%G? %h %ad | %s%d [%an]\" --date=short --graph

  # Pull
  pl = pull                         # pull

  # Push
  ps = push                         # push

  # Rebase
  rc = rebase --continue            # continue rebase
  rs = rebase --skip                # skip rebase

  # Remote
  r = remote -v                     # show remotes (verbose)

  # Reset
  unstage = reset HEAD              # remove files from index (tracking)
  uncommit = reset --soft HEAD^     # go back before last commit, with files in uncommitted state
  filelog = log -u                  # show changes to a file
  mt = mergetool                    # fire up the merge tool

  # Stash
  ss = stash                        # stash changes
  sl = stash list                   # list stashes
  sa = stash apply                  # apply stash (restore changes)
  sd = stash drop                   # drop stashes (destory changes)
  su = stash --include-untracked --keep-index     # stash only what's not in index

  # Status
  s = status                        # status
  st = status                       # status
  stat = status                     # status

  # Tag
  t = tag -n                        # show tags with <n> lines of each tag message

[format]
  pretty = format:%C(blue)%ad%Creset %C(yellow)%h%C(green)%d%Creset %C(blue)%s %C(magenta) [%an]%Creset

[mergetool]
  prompt = false

[merge]
  summary = true
  verbosity = 1
  tool = splice

[mergetool "splice"]
  cmd = "vim -f $BASE $LOCAL $REMOTE $MERGED -c 'SpliceInit'"
  trustExitCode = true

[apply]
  whitespace = nowarn

[branch]
  autosetuprebase = always

[push]
  default = simple

[core]
  autocrlf = false
  editor = vim
  excludesfile = ~/.gitignore

[advice]
  statusHints = true

[diff]
  # Git diff will use (i)ndex, (w)ork tree, (c)ommit and (o)bject
  # instead of a/b/c/d as prefixes for patches
  mnemonicprefix = true
''
