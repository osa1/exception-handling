open Types

type module_inst =
{
  types : func_type list;
  funcs : func_inst list;
  tables : table_inst list;
  memories : memory_inst list;
  tags : tag_inst list;
  globals : global_inst list;
  exports : export_inst list;
  elems : elem_inst list;
  datas : data_inst list;
}

and func_inst = module_inst ref Func.t
and table_inst = Table.t
and memory_inst = Memory.t
and tag_inst = Tag.t
and global_inst = Global.t
and export_inst = Ast.name * extern
and elem_inst = Values.ref_ list ref
and data_inst = string ref

and extern =
  | ExternFunc of func_inst
  | ExternTable of table_inst
  | ExternMemory of memory_inst
  | ExternTag of tag_inst
  | ExternGlobal of global_inst


(* Reference types *)

type Values.ref_ += FuncRef of func_inst

let () =
  let type_of_ref' = !Values.type_of_ref' in
  Values.type_of_ref' := function
    | FuncRef _ -> FuncRefType
    | r -> type_of_ref' r

let () =
  let string_of_ref' = !Values.string_of_ref' in
  Values.string_of_ref' := function
    | FuncRef _ -> "func"
    | r -> string_of_ref' r

let () =
  let eq_ref' = !Values.eq_ref' in
  Values.eq_ref' := fun r1 r2 ->
    match r1, r2 with
    | FuncRef f1, FuncRef f2 -> f1 == f2
    | _, _ -> eq_ref' r1 r2


(* Auxiliary functions *)

let empty_module_inst =
  { types = []; funcs = []; tables = []; memories = []; tags = [];
    globals = []; exports = []; elems = []; datas = [] }

let extern_type_of = function
  | ExternFunc func -> ExternFuncType (Func.type_of func)
  | ExternTable tab -> ExternTableType (Table.type_of tab)
  | ExternMemory mem -> ExternMemoryType (Memory.type_of mem)
  | ExternGlobal glob -> ExternGlobalType (Global.type_of glob)
  | ExternTag tag -> ExternTagType (Tag.type_of tag)

let export inst name =
  try Some (List.assoc name inst.exports) with Not_found -> None
