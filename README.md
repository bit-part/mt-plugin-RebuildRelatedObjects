RebuildRelatedObjects - Movable Type Plugin
=================

[Japanese](README.ja.md)

## Overview

Rebuild related entries or pages.

## Prerequisites

* Movable Type 6

## Installation

1. Unpack the RebuildRelatedObjects's archive.
1. Copy the "RebuildRelatedObjects" directory into /path/to/mt/plugins/

## Usage

### Step 1 : Prepare a field saving Entry/Page IDs

Prepare a field saving Entry/Page IDs on Entry/Page. You can use either a default field(ex."keywords") or Custom Fields.

### Step 2 : RebuildRelatedObjects Plugin setting

Save a basename of the field prepared at step1, to RebuildRelatedObjects Plugin setting. The basename of the field on Entry save to "Entry Field Basename". The basename of the field on Page save to "Page Field Basename".

Example:<br>
If you use keywords Field, you save "keywords".<br>
If you use a custom field whose basename is "foo", you save "field.foo".<br>
If you use both the fields, you save the comma separated field name; "keywords,field.foo".

### Step 3 : Save an ID in the field

You save an ID in the field. If you save some IDs, you can type IDs separated by comma.

### Step 4 : Just save the Entry/Page

When you save the Entry/Page, System rebuild entries/pages whose IDs you saved.

If you checked "Enable Mutual Relation" on plugin settings, the saved Entry/Page ID is saved in the same field of related entries/pages.

---

MT::Lover::bitpart
