(*
 * Copyright (c) 2013-2017 Thomas Gazagnaire <thomas@gazagnaire.org>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *)

open Lwt.Infix
open Test_common

module BlockCon = struct
  include Ramdisk
  let connect name = Ramdisk.connect ~name
end


(*let store = store (module Irmin_backend.Make) (module Irmin.Metadata.None)*)
let store = (module struct
  include Irmin_backend.KV_chunked(BlockCon)(Irmin_backend.StandardParams)(Irmin.Contents.String)
  let author _t _id = failwith "Only used for testing Git stores"
end : Test_common.Test_S)

(*
module Link = struct
  include Irmin_backend.Link(Irmin.Hash.SHA1)
  let v () = v (Irmin_backend.config ())
end

let link = (module Link: Test_link.S)
*)
let config = Irmin_backend.config ~path:"disk.img" ~create:true ()

let clean () =
  let (module S: Test_S) = store in
  S.Repo.v config >>= fun repo ->
  S.Repo.branches repo >>= Lwt_list.iter_p (S.Branch.remove repo)

let init () = Nocrypto_entropy_lwt.initialize ()
let stats = None
let suite = { name = "WODAN"; kind = `Core; init; clean; config; store; stats }