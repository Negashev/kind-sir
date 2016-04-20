# Kind Sir

Kind Sir is a [Gitlab](https://gitlab.com/) sattelite project.
It allows to automatically accept merge requests which got
specific number of upvotes during the code review.

Kind Sir is written in Scala and using Akka library heavily.

# How it works
Application reads config file and grab from Gitlab API list of
groups to monitor. For every group will be spawned supervisor actor.
Once per minute groups supervisor spawns Repo Worker actor for every repository in
this group.

Repo worker tries to find `.kind_sir.conf` file in the root of repository.
If there is no such file, worker will stop and repository will not
be processed. Otherwise Repo Worker will read this file and grab list of
opened Merge Requests for repository. After that it will check number of
upvotes and downvotes for every merge request and if request have
enought upvotes and satisfy Veto settings, Repo Worker will try to
merge it.

## Installation

- Git clone this repository
- Run `activator assembly` inside repository directory
- Grab `.jar` file produced by the `assembly` command
from `target/scala-2.11/` directory
- Deploy this file to target system
- Create Gitlab user on behalf of whom Kind Sir will be acting
- Add this user to any number of groups, you want to be monitored by Kind Sir
- Find `private_token` of this user in Gitlab's profile section
- Create configuration file described below
- Run `java -Dconfig.file=<your-config.con> <kind-sir-assembly.jar>`

## Configuration

Kind Sir using two kinds of configuration files:
1. Application configuration file, deployed with kind sir itself
2. Acceptance policy configuration placed in the root
of watched repository

### Application configuration file format

App configuration file is normal [Lightbend Config](https://github.com/typesafehub/config/) file.
There is only two fields you can specify at server side:
1. Gitlab URL
2. Private Token for user on whose behalf Kind Sir will be
acting.

For example, you create `config.conf` with this content:

```
kindSir {
  gitlab-url = "https://gitlab.acme.com"
  gitlab-token = "ex_MT1jP5t1DeSnN4ka9"
}
```

After that you can run Kind Sir with command:
```
java -Dconfig.file=config.conf kind-sir-assembly-0.1.jar`
```

### Acceptance policy

In the root of every repository you want to be monitored by Kind Sir
should be placed policy config file named `.kind_sir.conf`. This is a
regular JSON file.

You can find example of this file right in this repository.
```
$ ls -la
total 56
drwxr-xr-x  14 nsa  staff   476 20 апр 22:47 .
drwxr-xr-x  21 nsa  staff   714 20 апр 15:19 ..
-rw-r--r--@  1 nsa  staff  8196 18 апр 07:46 .DS_Store
drwxr-xr-x  16 nsa  staff   544 20 апр 22:47 .git
-rw-r--r--   1 nsa  staff  1606 17 апр 19:19 .gitignore
drwxr-xr-x  13 nsa  staff   442 20 апр 22:47 .idea
-rw-r--r--   1 nsa  staff    53 19 апр 14:56 .kind_sir.conf <==== Here it is
-rw-r--r--   1 nsa  staff  1549 20 апр 22:47 README.md
drwxr-xr-x   5 nsa  staff   170 17 апр 15:45 bin
-rw-r--r--   1 nsa  staff   437 20 апр 15:27 build.sbt
drwxr-xr-x   3 nsa  staff   102 17 апр 13:42 libexec
drwxr-xr-x   7 nsa  staff   238 17 апр 15:01 project
drwxr-xr-x   4 nsa  staff   136 19 апр 14:56 src
drwxr-xr-x   8 nsa  staff   272 17 апр 15:54 target
```

There is also only two things to specify:
1. Upvotes threshold after which request should be accepted
2. Is Veto enabled. If true request will never be accepted if there is
at least one downvote.

Example:
```
{
  "upvotes_threshold": 2,
  "veto_enabled": false
}
```

This means any Merge Request which got two upvotes or more will be
merged by Kind Sir. Downvotes doesn't accounted at all.