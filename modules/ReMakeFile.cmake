############################################################################
#    Copyright (C) 2013 by Ralf Kaestner                                   #
#    ralf.kaestner@gmail.com                                               #
#                                                                          #
#    This program is free software; you can redistribute it and#or modify  #
#    it under the terms of the GNU General Public License as published by  #
#    the Free Software Foundation; either version 2 of the License, or     #
#    (at your option) any later version.                                   #
#                                                                          #
#    This program is distributed in the hope that it will be useful,       #
#    but WITHOUT ANY WARRANTY; without even the implied warranty of        #
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         #
#    GNU General Public License for more details.                          #
#                                                                          #
#    You should have received a copy of the GNU General Public License     #
#    along with this program; if not, write to the                         #
#    Free Software Foundation, Inc.,                                       #
#    59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             #
############################################################################

include(ReMakePrivate)

### \brief ReMake file macros
#   The ReMake file macros are a set of helper macros to simplify
#   file operations in ReMake.

if(NOT DEFINED REMAKE_FILE_CMAKE)
  remake_set(REMAKE_FILE_CMAKE ON)

  remake_set(REMAKE_FILE_DIR ReMakeFiles)
endif(NOT DEFINED REMAKE_FILE_CMAKE)

### \brief Define a ReMake file.
#   This macro creates a variable to hold the ReMake-compliant path to a
#   a regular file or directory with the specified name. If the file or
#   directory name contains a relative path, it is assumed to be located
#   below the ReMake directory ${REMAKE_FILE_DIR}.
#   \required[value] variable name of the output variable to be assigned the
#     ReMake path to the file or directory.
#   \required[value] filename The name of a file or directory.
#   \optional[option] TOPLEVEL If this option is present, the relative-path
#     file or directory is assumed to be located in the top-level ReMake
#     directory below ${CMAKE_BINARY_DIR}. Otherwise, the file or directory
#     resides in the local ReMake directory below ${CMAKE_CURRENT_BINARY_DIR}.
macro(remake_file file_var file_name)
  remake_arguments(PREFIX file_ OPTION TOPLEVEL ${ARGN})

  if(IS_ABSOLUTE ${file_name})
    remake_set(${file_var} ${file_name})
  else(IS_ABSOLUTE ${file_name})
    if(file_toplevel)
      remake_set(${file_var}
        ${CMAKE_BINARY_DIR}/${REMAKE_FILE_DIR}/${file_name})
    else(file_toplevel)
      remake_set(${file_var}
        ${CMAKE_CURRENT_BINARY_DIR}/${REMAKE_FILE_DIR}/${file_name})
    endif(file_toplevel)
  endif(IS_ABSOLUTE ${file_name})
endmacro(remake_file)

### \brief Output a valid file or directory name from a set of strings.
#   This macro is a helper macro to generate valid filenames from arbitrary
#   strings. It replaces whitespace characters and CMake list separators by
#   underscores and performs a lower-case conversion of the result.
#   \required[value] variable The name of a variable to be assigned the
#     generated filename.
#   \required[list] string A list of strings to be concatenated to the
#     filename.
macro(remake_file_name file_var)
  string(TOLOWER "${ARGN}" file_lower)
  string(REGEX REPLACE "[ ;]" "_" ${file_var} "${file_lower}")
endmacro(remake_file_name)

### \brief Substitute selected components of filenames.
#   This macro substitutes the components of a list of filenames. Specifically,
#   one can choose to replace the filename's path, name, or extension.
#   \required[value] variable The name of the variable that is assigned the
#     list of substituted filenames.
#   \required[list] filename The list of input filenames to be substituted.
#   \optional[value] PATH:path The path to be used as a subsitute to the
#     filenames' paths.
#   \optional[option] TO_ABSOLUTE With this option provided, a filename's
#     path will only be substituted if it indicates a relative path.
#   \optional[value] NAME_WE:name The name to be used as a subsitute to the
#     filenames' names (excluding the extension).
#   \optional[value] EXT:extension The extension to be used as a subsitute
#     to the filenames' extensions, without the leading period.
macro(remake_file_name_substitute file_var)
  remake_arguments(PREFIX file_ VAR PATH OPTION TO_ABSOLUTE VAR NAME_WE
    VAR EXT ARGN names ${ARGN})

  remake_set(${file_var})
  foreach(file_name ${file_names})
    get_filename_component(file_org_path ${file_name} PATH)
    get_filename_component(file_org_name_we ${file_name} NAME_WE)
    get_filename_component(file_org_ext ${file_name} EXT)

    if(file_path)
      if(file_to_absolute)
        if(IS_ABSOLUTE ${file_org_path})
          remake_set(file_substitute "${file_org_path}")
        else(IS_ABSOLUTE ${file_org_path})
          remake_set(file_substitute "${file_path}")
        endif(IS_ABSOLUTE ${file_org_path})
      else(file_to_absolute)
        remake_set(file_substitute "${file_path}")
      endif(file_to_absolute)
    else(file_path)
      remake_set(file_substitute "${file_org_path}")
    endif(file_path)

    if(file_name_we)
      remake_set(file_substitute "${file_substitute}/${file_name_we}")
    else(file_name_we)
      remake_set(file_substitute "${file_substitute}/${file_org_name_we}")
    endif(file_name_we)

    if(file_ext)
      remake_set(file_substitute "${file_substitute}.${file_ext}")
    else(file_ext)
      remake_set(file_substitute "${file_substitute}${file_org_ext}")
    endif(file_ext)

    remake_list_push(${file_var} ${file_substitute})
  endforeach(file_name)
endmacro(remake_file_name_substitute)

### \brief Prepend a list of prefixes to a filename.
#   This macro prepends a list of prefixes to a filename. The prefixes are
#   prepended to the filename itself, not to the filename's path.
#   \required[value] variable The name of the variable that is assigned the
#     resulting prefixed filename.
#   \required[value] filename The input filename to be prefixed.
#   \optional[option] STRIP If present, this option causes the macro to
#     only return the prefixed filename whilst any path information will be
#     stripped from the output.
#   \required[list] prefix The list of prefixes to be prepended to the
#     filename. Note that the list can be empty in which case the input
#     filename is returned.
macro(remake_file_prefix file_var file_name)
  remake_arguments(PREFIX file_ OPTION STRIP ARGN prefixes ${ARGN})

  if(file_strip)
    remake_set(file_path)
  else(file_strip)
    get_filename_component(file_path ${file_name} PATH)
  endif(file_strip)
  get_filename_component(file_name_ext ${file_name} NAME)

  if(file_path)
    remake_set(${file_var} "${file_path}/")
  else(file_path)
    remake_set(${file_var})
  endif(file_path)
  foreach(file_prefix ${file_prefixes})
    remake_set(${file_var} "${${file_var}}${file_prefix}")
  endforeach(file_prefix)
  remake_set(${file_var} "${${file_var}}${file_name_ext}")
endmacro(remake_file_prefix)

### \brief Append a list of suffixes to a filename.
#   This macro appends a list of suffixes to a filename. The suffixes are
#   appended to the filename itself, not to the filename's extension.
#   \required[value] variable The name of the variable that is assigned the
#     resulting suffixed filename.
#   \required[value] filename The input filename to be suffixed.
#   \optional[option] STRIP If present, this option causes the macro to
#     only return the suffixed filename whilst any path information will be
#     stripped from the output.
#   \required[list] suffix The list of suffixes to be appended to the
#     filename. Note that the list can be empty in which case the input
#     filename is returned.
macro(remake_file_suffix file_var file_name)
  remake_arguments(PREFIX file_ OPTION STRIP ARGN suffixes ${ARGN})

  if(file_strip)
    remake_set(file_path)
  else(file_strip)
    get_filename_component(file_path ${file_name} PATH)
  endif(file_strip)
  get_filename_component(file_name_we ${file_name} NAME_WE)
  get_filename_component(file_ext ${file_name} EXT)

  if(file_path)
    remake_set(${file_var} "${file_path}/")
  else(file_path)
    remake_set(${file_var})
  endif(file_path)
  remake_set(${file_var} "${${file_var}}${file_name_we}")
  foreach(file_suffix ${file_suffixes})
    remake_set(${file_var} "${${file_var}}${file_suffix}")
  endforeach(file_suffix)
  if(file_ext)
    remake_set(${file_var} "${${file_var}}${file_ext}")
  endif(file_ext)
endmacro(remake_file_suffix)

### \brief Find files or directories using a glob expression.
#   This macro searches the current directory for files or directories having
#   names that match any of the glob expression passed to the macro and returns
#   a result list of file/directory names. By default, hidden files/directories
#   will be excluded from the result list.
#   \required[value] variable The name of the output variable to hold the
#     matched file/directory names.
#   \required[list] glob A list of glob expressions that is passed to CMake's
#     file(GLOB ...) macro. See the CMake documentation for usage.
#   \optional[value] WORKING_DIRECTORY:dirname An optional directory name that
#     refers to the working directory for resolving relative-path glob
#     expressions, defaults to ${CMAKE_CURRENT_SOURCE_DIR}.
#   \optional[option] RELATIVE If called with this option, the macro returns
#     relative-path file and directory names with respect to the specified
#     working directory. If no working directory is provided, the option will
#     not affect the output.
#   \optional[option] HIDDEN If present, this option prevents hidden
#     files/directories from being excluded from the result list.
#   \optional[option] FILES If present, this option causes the macro
#     to find regular files. Note that this is the default behavior. However,
#     passing the option may prove useful in cases where both, files and
#     directories, shall be included in the result list.
#   \optional[option] DIRECTORIES If present, this option causes the macro
#     to find directories. With the FILES option being passed in addition,
#     regular files are also included in the result list.
#   \optional[list] RECURSE:dirname An optional list of directories that will
#     be searched recursively for files or directories matching the given
#     glob expressions.
#   \optional[list] EXCLUDE:filename An optional list of file/directory names
#     that shall be excluded from the result list.
macro(remake_file_glob file_var)
  remake_arguments(PREFIX file_ VAR WORKING_DIRECTORY OPTION RELATIVE
    OPTION HIDDEN OPTION FILES OPTION DIRECTORIES LIST RECURSE LIST EXCLUDE
    ARGN globs ${ARGN})
  remake_set(file_working_directory SELF DEFAULT ${CMAKE_CURRENT_SOURCE_DIR})

  remake_set(file_working_recurse)
  foreach(file_dir ${file_recurse})
    if(IS_ABSOLUTE ${file_dir})
      remake_list_push(file_working_recurse ${file_dir})
    else(IS_ABSOLUTE ${file_dir})
      remake_list_push(file_working_recurse
        ${file_working_directory}/${file_dir})
    endif(IS_ABSOLUTE ${file_dir})
  endforeach(file_dir)

  remake_set(file_working_globs)
  foreach(file_glob ${file_globs})
    if(file_recurse)
      foreach(file_dir ${file_working_recurse})
        remake_list_push(file_working_globs
          ${file_working_recurse}/${file_glob})
      endforeach(file_dir)
    else(file_recurse)
      if(IS_ABSOLUTE ${file_glob})
        remake_list_push(file_working_globs ${file_glob})
      else(IS_ABSOLUTE ${file_glob})
        remake_list_push(file_working_globs
          ${file_working_directory}/${file_glob})
      endif(IS_ABSOLUTE ${file_glob})
    endif(file_recurse)
  endforeach(file_glob)

  foreach(file_glob ${file_working_globs})
    if(IS_DIRECTORY ${file_glob})
      get_filename_component(file_glob_absolute ${file_glob} ABSOLUTE)
      remake_list_replace(file_working_globs ${file_glob}
        REPLACE ${file_glob_absolute} VERBATIM)
    endif(IS_DIRECTORY ${file_glob})
  endforeach(file_glob)

  if(file_recurse)
    file(GLOB_RECURSE file_names ${file_working_globs})
  else(file_recurse)
    file(GLOB file_names ${file_working_globs})
  endif(file_recurse)

  remake_set(${file_var})
  foreach(file_name ${file_names})
    get_filename_component(file_name_absolute ${file_name} ABSOLUTE)
    remake_list_push(${file_var} ${file_name_absolute})
  endforeach(file_name)

  if(NOT file_directories)
    foreach(file_name ${${file_var}})
      if(IS_DIRECTORY ${file_name})
        list(REMOVE_ITEM ${file_var} ${file_name})
      endif(IS_DIRECTORY ${file_name})
    endforeach(file_name)
    remake_set(file_files ON)
  endif(NOT file_directories)

  if(NOT file_files)
    foreach(file_name ${${file_var}})
      if(NOT IS_DIRECTORY ${file_name})
        list(REMOVE_ITEM ${file_var} ${file_name})
      endif(NOT IS_DIRECTORY ${file_name})
    endforeach(file_name)
  endif(NOT file_files)

  if(NOT file_hidden)
    foreach(file_name ${${file_var}})
      file(RELATIVE_PATH file_name_relative ${file_working_directory}
        ${file_name})
      if(${file_name_relative} MATCHES "^[.][^.][^/]*$")
        list(REMOVE_ITEM ${file_var} ${file_name})
      endif(${file_name_relative} MATCHES "^[.][^.][^/]*$")
      if(${file_name_relative} MATCHES "^[.][^.][^/]*/.*$")
        list(REMOVE_ITEM ${file_var} ${file_name})
      endif(${file_name_relative} MATCHES "^[.][^.][^/]*/.*$")
      if(${file_name_relative} MATCHES "^.*/[.][^.][^/]*/.*$")
        list(REMOVE_ITEM ${file_var} ${file_name})
      endif(${file_name_relative} MATCHES "^.*/[.][^.][^/]*/.*$")
      if(${file_name_relative} MATCHES "^.*/[.][^.][^/]*$")
        list(REMOVE_ITEM ${file_var} ${file_name})
      endif(${file_name_relative} MATCHES "^.*/[.][^.][^/]*$")
    endforeach(file_name)
  endif(NOT file_hidden)

  foreach(file_exclude_name ${file_exclude})
    foreach(file_name ${${file_var}})
      file(RELATIVE_PATH file_name_relative ${file_working_directory}
        ${file_name})
      if(${file_name_relative} MATCHES "^${file_exclude_name}$")
        list(REMOVE_ITEM ${file_var} ${file_name})
      endif(${file_name_relative} MATCHES "^${file_exclude_name}$")
      if(${file_name_relative} MATCHES "^${file_exclude_name}/.*$")
        list(REMOVE_ITEM ${file_var} ${file_name})
      endif(${file_name_relative} MATCHES "^${file_exclude_name}/.*$")
      if(${file_name_relative} MATCHES "^.*/${file_exclude_name}/.*$")
        list(REMOVE_ITEM ${file_var} ${file_name})
      endif(${file_name_relative} MATCHES "^.*/${file_exclude_name}/.*$")
      if(${file_name_relative} MATCHES "^.*/${file_exclude_name}$")
        list(REMOVE_ITEM ${file_var} ${file_name})
      endif(${file_name_relative} MATCHES "^.*/${file_exclude_name}$")
    endforeach(file_name)
  endforeach(file_exclude_name)

  if(file_relative)
    foreach(file_name ${${file_var}})
      file(RELATIVE_PATH file_name_relative ${file_working_directory}
        ${file_name})
      remake_list_replace(${file_var} ${file_name}
        REPLACE ${file_name_relative} VERBATIM)
    endforeach(file_name)
  endif(file_relative)
endmacro(remake_file_glob)

### \brief Create a directory.
#   This macro creates a ReMake directory. The directory name is automatically
#   converted into a ReMake location by a call to remake_file().
#   \required[value] dirname The name of the directory to be created.
#   \optional[option] TOPLEVEL If this option is present, the directory
#     to be created is a top-level ReMake directory.
macro(remake_file_mkdir file_dir_name)
  remake_arguments(PREFIX file_ OPTION TOPLEVEL ${ARGN})
  remake_file(file_dir ${file_dir_name} ${TOPLEVEL})

  if(NOT IS_DIRECTORY  ${file_dir})
    file(MAKE_DIRECTORY ${file_dir})
  endif(NOT IS_DIRECTORY ${file_dir})
endmacro(remake_file_mkdir)

### \brief Recursively remove a directory.
#   This macro recursively removes a ReMake directory. The directory name
#   is automatically converted into a ReMake location by a call to
#   remake_file().
#   \required[value] dirname The name of the directory to be removed.
#   \optional[option] TOPLEVEL If this option is present, the directory
#     to be removed is a top-level ReMake directory.
macro(remake_file_rmdir file_dir_name)
  remake_arguments(PREFIX file_ OPTION TOPLEVEL ${ARGN})
  remake_file(file_dir ${file_dir_name} ${TOPLEVEL})

  if(IS_DIRECTORY  ${file_dir})
    file(REMOVE_RECURSE ${file_dir})
  endif(IS_DIRECTORY ${file_dir})
endmacro(remake_file_rmdir)

### \brief Create an empty file.
#   This macro creates an empty ReMake file. The filename is automatically
#   converted into a ReMake location by a call to remake_file(). Optionally,
#   the macro allows for selectively re-creating outdated files. Therefore,
#   the file modification date is tested against ReMake's timestamp file,
#   a special file created at inclusion time.
#   \required[value] filename The name of the file to be created.
#   \optional[option] OUTDATED If present, this option prevents files with
#      a recent modification timestamp from being re-created.
#   \optional[option] TOPLEVEL If this option is present, the file
#     to be created is a top-level ReMake file.
macro(remake_file_create file_name)
  remake_arguments(PREFIX file_ OPTION TOPLEVEL OPTION OUTDATED ${ARGN})
  remake_file(file_create ${file_name} ${TOPLEVEL})

  if(EXISTS ${file_create})
    if(file_outdated)
      if(NOT ${file_create} IS_NEWER_THAN ${REMAKE_FILE_TIMESTAMP})
        file(WRITE ${file_create})
      endif(NOT ${file_create} IS_NEWER_THAN ${REMAKE_FILE_TIMESTAMP})
    else(file_outdated)
      file(WRITE ${file_create})
    endif(file_outdated)
  else(EXISTS ${file_create})
    file(WRITE ${file_create})
  endif(EXISTS ${file_create})
endmacro(remake_file_create)

### \brief Read content from file.
#   This macro reads file content into a string variable. The name of the file
#   to be read is automatically converted into a ReMake location by a call to
#   remake_file().
#   \required[value] variable The name of a string variable to be assigned
#     the file's content.
#   \required[value] filename The name of the file to be read from.
#   \optional[option] TOPLEVEL If this option is present, the file
#     to be read is a top-level ReMake file.
macro(remake_file_read file_var file_name)
  remake_arguments(PREFIX file_ OPTION TOPLEVEL ${ARGN})
  remake_file(file_read ${file_name} ${TOPLEVEL})

  if(EXISTS ${file_read})
    file(READ ${file_read} ${file_var})
  else(EXISTS ${file_read})
    remake_set(${file_var})
  endif(EXISTS ${file_read})
endmacro(remake_file_read)

### \brief Write content to file.
#   This macro appends a list of string values to a file. The name of the file
#   to be written is automatically converted into a ReMake location by a call
#   to remake_file(). If the file does not exist yet, it will automatically
#   be created.
#   \required[value] filename The name of the file to be written to.
#   \optional[option] TOPLEVEL If this option is present, the file
#     to be written is a top-level ReMake file.
#   \optional[option] LINES If provided, this options causes each element
#     in the list of strings to be appended as an individual line.
#   \optional[value] FROM:variable The name of a variable holding the content
#     to be written. Passing file content by reference makes the macro
#     ignore all additional string values and the LINES option, and is
#     particularly useful in the presence of escape characters. Whereas
#     value passing generally causes CMake to resolve escape sequences,
#     reference passing does not suffer from such modifications.
#   \optional[list] string The list of strings to be appended to the file.
macro(remake_file_write file_name)
  remake_arguments(PREFIX file_ OPTION TOPLEVEL OPTION LINES VAR FROM
    ARGN strings ${ARGN})
  remake_file(file_write ${file_name} ${TOPLEVEL})

  if(EXISTS ${file_write})
    file(READ ${file_write} file_not_empty)
    if(file_not_empty)
      if(file_lines)
        file(APPEND ${file_write} "\n")
      else(file_lines)
        file(APPEND ${file_write} ";")
      endif(file_lines)
    endif(file_not_empty)
  else(EXISTS ${file_write})
    file(WRITE ${file_write})
  endif(EXISTS ${file_write})

  if(file_from)
    file(APPEND ${file_write} "${${file_from}}")
  else(file_from)
    if(file_lines)
      string(REGEX REPLACE ";" "\n" file_strings "${file_strings}")
    endif(file_lines)
    file(APPEND ${file_write} "${file_strings}")
  endif(file_from)
endmacro(remake_file_write)

### \brief Copy files.
#   This macro copies one or multiple files. The destination is automatically
#   converted into a ReMake location by a call to remake_file().
#   \required[value] destination The name of the destination file or
#     directory. If a directory name is provided, the files will be
#     copied into the specified directory whilst the names will be preserved.
#   \required[list] glob A list of glob expressions that are matched to find
#     the source files. Note that if the glob expression resolves to multiple
#     files, the destination will be required to name a directory.
#   \optional[var] OUTPUT:variable The optional name of a list variable to
#     be assigned all destination filenames.
#   \optional[option] TOPLEVEL If this option is present, the destination
#     is a top-level ReMake file or directory.
macro(remake_file_copy file_copy_destination)
  remake_arguments(PREFIX file_copy_ VAR OUTPUT OPTION TOPLEVEL
    ARGN globs ${ARGN})
  remake_file(file_copy_dst ${file_copy_destination} ${TOPLEVEL})

  if(file_copy_output)
    remake_set(${file_copy_output})
  endif(file_copy_output)

  remake_file_glob(file_copy_sources FILES ${file_copy_globs})
  foreach(file_copy_src ${file_copy_sources})
    if(IS_DIRECTORY ${file_copy_dst})
      get_filename_component(file_copy_name ${file_copy_src} NAME)
      remake_set(file_copy_dst_name ${file_copy_dst}/${file_copy_name})
    else(IS_DIRECTORY ${file_copy_dst})
      remake_set(file_copy_dst_name ${file_copy_dst})
    endif(IS_DIRECTORY ${file_copy_dst})

    execute_process(COMMAND ${CMAKE_COMMAND} -E copy ${file_copy_src}
      ${file_copy_dst_name})

    if(file_copy_output)
      remake_list_push(${file_copy_output} ${file_copy_dst_name})
    endif(file_copy_output)
  endforeach(file_copy_src)
endmacro(remake_file_copy)

### \brief Concatenate lines from input files into an output file.
#   This macro concatenates lines of multiple input files into an
#   output file. Thereby, the input files are considered in the
#   alphabetical order of their filenames.
#   \required[value] filename The name of the output file which will
#     hold the concatenated lines of all input files in order of
#     their specification.
#   \required[list] glob A list of glob expressions that are matched to
#     find the input files. Note that the order in which files are
#     matched will affect the output.
#   \optional[option] APPEND If this option is present, the output
#     file will be appended the concatenated input file lines.
#   \optional[option] TOPLEVEL If this option is present, the output
#     file is a top-level ReMake file.
macro(remake_file_cat file_cat_name)
  remake_arguments(PREFIX file_cat_ OPTION APPEND OPTION TOPLEVEL
    ARGN globs ${ARGN})

  remake_file(file_cat_output ${file_cat_name} ${TOPLEVEL})
  remake_file_glob(file_cat_inputs FILES ${file_cat_globs})
  list(SORT file_cat_inputs)

  if(NOT file_cat_append)
    remake_file_create(${file_cat_output})
  endif(NOT file_cat_append)
  foreach(file_cat_input ${file_cat_inputs})
    remake_file_read(file_cat_content ${file_cat_input})
    remake_file_write(${file_cat_output} LINES FROM file_cat_content)
  endforeach(file_cat_input)
endmacro(remake_file_cat)

### \brief Set file permissions.
#   This macro sets the permissions on a file. Therefore, a temporary copy
#   of the file is first created to establish the permissions. Then, the
#   temporary copy is renamed to replace the original file.
#   \required[value] filename The name of the file to set the permissions for.
#   \required[list] perm A list of permission flags as supported by CMake's
#     install() macro. See the CMake documentation for details.
macro(remake_file_permissions file_name)
  remake_arguments(PREFIX file_perm_ ARGN permissions ${ARGN})

  file(COPY ${file_name} DESTINATION ${CMAKE_BINARY_DIR}/${REMAKE_FILE_DIR}
    FILE_PERMISSIONS ${file_perm_permissions})
  get_filename_component(file_perm_name ${file_name} NAME)
  file(RENAME ${CMAKE_BINARY_DIR}/${REMAKE_FILE_DIR}/${file_perm_name}
    ${file_name})
endmacro(remake_file_permissions)

### \brief Link files.
#   This macro links one or multiple files. The destination is automatically
#   converted into a ReMake location by a call to remake_file().
#   \required[value] destination The name of the destination file or
#     directory. If a directory name is provided, the files will be
#     linked into the specified directory whilst the names will be preserved.
#   \required[list] glob A list of glob expressions that are matched to find
#     the source files. Note that if the glob expression resolves to multiple
#     files, the destination will be required to name a directory.
#   \optional[var] OUTPUT:variable The optional name of a list variable to
#     be assigned all link filenames.
#   \optional[option] TOPLEVEL If this option is present, the destination
#     is a top-level ReMake file or directory.
macro(remake_file_link file_link_destination)
  remake_arguments(PREFIX file_link_ VAR OUTPUT OPTION TOPLEVEL
    ARGN globs ${ARGN})
  remake_file(file_link_dst ${file_link_destination} ${TOPLEVEL})

  if(file_link_output)
    remake_set(${file_link_output})
  endif(file_link_output)

  remake_file_glob(file_link_sources FILES ${file_link_globs})
  foreach(file_link_src ${file_link_sources})
    if(IS_DIRECTORY ${file_link_dst})
      get_filename_component(file_link_name ${file_link_src} NAME)
      remake_set(file_link_dst_name ${file_link_dst}/${file_link_name})
    else(IS_DIRECTORY ${file_link_dst})
      remake_set(file_link_dst_name ${file_link_dst})
    endif(IS_DIRECTORY ${file_link_dst})

    execute_process(COMMAND ${CMAKE_COMMAND} -E create_symlink
      ${file_link_src} ${file_link_dst_name})

    if(file_link_output)
      remake_list_push(${file_link_output} ${file_link_dst_name})
    endif(file_link_output)
  endforeach(file_link_src)
endmacro(remake_file_link)

### \brief Configure files using ReMake variables.
#   This macro takes a glob expression and, in all matching input files being
#   newer than their respective output files, replaces variables referenced
#   as ${VAR} with their values as determined by CMake.
#   The macro actually configures files with a .remake extension, but copies
#   files that do not match this naming convention. By default, the
#   configured file's output path is the relative source path below
#   ${CMAKE_CURRENT_BINARY_DIR}. The .remake extension is automatically
#   stripped from the output filenames.
#   \required[list] glob A list of glob expressions that are matched to find
#     the input files.
#   \optional[var] DESTINATION:dirname The optional destination
#     path for output files generated by this macro, defaults to
#     ${CMAKE_CURRENT_BINARY_DIR}.
#   \optional[var] EXT:extension An optional extension that will be appended
#     to all output filenames, without the leading period.
#   \optional[var] OUTPUT:variable The optional name of a list variable to
#     be assigned all absolute-path output filenames.
#   \optional[option] OUTDATED If present, this option prevents files with
#      a recent modification timestamp from being re-configured.
#   \optional[option] ESCAPE_QUOTES If specified, any substituted quotes
#     will be C-style escaped.
#   \optional[option] ESCAPE_NEWLINES If specified, any substituted line
#     breaks will be C-style escaped.
#   \optional[value] LIST_SEPARATOR:string An optional string which will
#     substitute CMake's list separator in the output files.
#   \optional[option] STRIP_PATHS This option causes the macro to strip
#     any directories from the relative-path output filenames and to
#     directly place the output files under the destination directory.
macro(remake_file_configure)
  remake_arguments(PREFIX file_conf_ VAR DESTINATION VAR EXT VAR OUTPUT
    OPTION OUTDATED OPTION ESCAPE_QUOTES OPTION ESCAPE_NEWLINES
    VAR LIST_SEPARATOR OPTION STRIP_PATHS ARGN globs ${ARGN})
  remake_set(file_conf_destination SELF DEFAULT ${CMAKE_CURRENT_BINARY_DIR})

  if(file_conf_output)
    set(${file_conf_output})
  endif(file_conf_output)

  remake_file_glob(file_conf_sources ${file_conf_globs} RELATIVE)
  foreach(file_conf_src ${file_conf_sources})
    remake_file_read(file_conf_content
      ${CMAKE_CURRENT_SOURCE_DIR}/${file_conf_src})
    if(file_conf_src MATCHES "[.]remake$")
      if(file_conf_strip_paths)
        get_filename_component(file_conf_src_name ${file_conf_src} NAME)
        remake_set(file_conf_dst
          ${file_conf_destination}/${file_conf_src_name})
      else(file_conf_strip_paths)
        remake_set(file_conf_dst ${file_conf_destination}/${file_conf_src})
      endif(file_conf_strip_paths)
      string(REGEX REPLACE "[.]remake$" "" file_conf_dst ${file_conf_dst})
      if(file_conf_ext)
        remake_set(file_conf_dst ${file_conf_dst}.${file_conf_ext})
      endif(file_conf_ext)

      get_filename_component(file_conf_src_abs ${file_conf_src} ABSOLUTE)
      get_filename_component(file_conf_dst_abs ${file_conf_dst} ABSOLUTE)

      if(NOT file_conf_outdated OR ${file_conf_src_abs} IS_NEWER_THAN
          ${file_conf_dst_abs})
        get_cmake_property(file_conf_globals VARIABLES)
        string(REGEX MATCHALL "\\\${[a-zA-Z_]*}" file_conf_vars
          ${file_conf_content})
        remake_list_remove_duplicates(file_conf_vars)

        foreach(file_conf_var ${file_conf_vars})
          string(REGEX REPLACE "\\\${([a-zA-Z_]*)}" "\\1" file_conf_var
            ${file_conf_var})
          remake_set(file_conf_value "${${file_conf_var}}")
          if(file_conf_list_separator)
            string(REPLACE ";" "${file_conf_list_separator}"
              file_conf_value "${file_conf_value}")
          endif(file_conf_list_separator)
          if(file_conf_escape_quotes)
            string(REGEX REPLACE "\"" "\\\\\"" file_conf_value
              "${file_conf_value}")
          endif(file_conf_escape_quotes)
          if(file_conf_escape_newlines)
            string(REGEX REPLACE "\n" "\\\\n" file_conf_value
              "${file_conf_value}")
          endif(file_conf_escape_newlines)
          string(REPLACE "\${${file_conf_var}}" "${file_conf_value}"
            file_conf_content "${file_conf_content}")
        endforeach(file_conf_var)

        remake_file_create(${file_conf_dst})
        remake_file_write(${file_conf_dst} FROM file_conf_content)
        configure_file(${file_conf_dst} ${file_conf_dst})
      endif(NOT file_conf_outdated OR ${file_conf_src_abs} IS_NEWER_THAN
        ${file_conf_dst_abs})
    else(file_conf_src MATCHES "[.]remake$")
      if(file_conf_strip_paths)
        get_filename_component(file_conf_src_name ${file_conf_src} NAME)
        remake_set(file_conf_dst
          ${file_conf_destination}/${file_conf_src_name})
      else(file_conf_strip_paths)
        remake_set(file_conf_dst ${file_conf_destination}/${file_conf_src})
      endif(file_conf_strip_paths)
      if(file_conf_ext)
        remake_set(file_conf_dst ${file_conf_dst}.${file_conf_ext})
      endif(file_conf_ext)

      get_filename_component(file_conf_src_abs ${file_conf_src} ABSOLUTE)
      get_filename_component(file_conf_dst_abs ${file_conf_dst} ABSOLUTE)

      if(NOT file_conf_outdated OR ${file_conf_src_abs} IS_NEWER_THAN
          ${file_conf_dst_abs})
        remake_file_copy(${file_conf_dst} ${file_conf_src})
      endif(NOT file_conf_outdated OR ${file_conf_src_abs} IS_NEWER_THAN
        ${file_conf_dst_abs})
    endif(file_conf_src MATCHES "[.]remake$")

    if(file_conf_output)
      list(APPEND ${file_conf_output} ${file_conf_dst})
    endif(file_conf_output)
  endforeach(file_conf_src)
endmacro(remake_file_configure)

if(NOT DEFINED REMAKE_FILE_TIMESTAMP)
  remake_file(REMAKE_FILE_TIMESTAMP timestamp)
  remake_file_create(${REMAKE_FILE_TIMESTAMP})
endif(NOT DEFINED REMAKE_FILE_TIMESTAMP)
