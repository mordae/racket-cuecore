#lang scribble/manual

@require[(for-label cuecore)
         (for-label typed/racket/base)
         (for-label typed/racket/class)]

@title{CueCore Lighting Control}
@author+email["Jan Dvořák" "mordae@anilinux.org"]


@defmodule[cuecore]

@defidform[CueCore%]{
  Type of the @racket[cuecore%] class.
}

@defidform[Group]{
  Type representing a valid group identifier.
  Equivalent to @racket[Natural] numbers in the @tt{0..15} range.
}

@defclass[cuecore% object% ()]{
  CueCore device proxy.

  @defconstructor[((host String))]{
    Connect to a CueCore device running on specified address or a host name
    passed as the @racket[host] field.
  }

  @defmethod[(set-channel! (channel Natural) (value Natural)) Void]{
    Set specified @racket[channel] to the given @racket[value].

    Acceptable channels are in the range @tt{1..1024} and values in the
    range @tt{0..255}. Values larger than @tt{255} are rounded down.
    Channels larger than @tt{1024} are ignored.

    Note that channels @tt{1..512} are present on the @tt{DMX output A}
    and channels @tt{513..1024} on the @tt{DMX output B}.
  }

  @defmethod[(get-status (group Group)) (Listof Natural)]{
    Retrieve status of specified channel group.
    Every channel group holds @tt{64} channels.
    Groups @tt{0..7} map to @tt{DMX output A},
    groups @tt{8..15} map to @tt{DMX output B}.
  }
}


@; vim:set ft=scribble sw=2 ts=2 et:
