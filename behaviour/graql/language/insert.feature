#
# Copyright (C) 2020 Grakn Labs
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#
Feature: Graql Insert Query

  Background: Open connection
    Given connection has been opened
    Given connection delete all keyspaces
    Given connection open sessions for keyspaces:
      | test_insert |
    Given transaction is initialised
    Given the integrity is validated
    Given graql define
      """
      define
      person sub entity,
        plays employee,
        has name,
        key ref;
      company sub entity,
        plays employer,
        key ref;
      employment sub relation,
        relates employee,
        relates employer,
        key ref;
      name sub attribute,
        value string,
        key ref;
      ref sub attribute,
        value long;
      """
    Given the integrity is validated


  # TODO: make 3 tests: entity, attribute, relation
  Scenario: insert an instance creates instance of that type
    When graql insert
      """
      insert
      $name "John" isa name, has ref 0;
      $x isa person, has name $name, has ref 1;
      """
    When the integrity is validated

    When get answers of graql query
      """
      match $x isa thing; $x has name "John"; get;
      """
    Then concept identifiers are
      |     | check | value |
      | JHN | key   | ref:1 |
    Then uniquely identify answer concepts
      | x   |
      | JHN |


  Scenario: an attribute value can be set on insert when its value type is `string`

  Scenario: an attribute value can be set on insert when its value type is `long`

  Scenario: an attribute value can be set on insert when its value type is `double`

  Scenario: an attribute value can be set on insert when its value type is `boolean`

  Scenario: an attribute value can be set on insert when its value type is `datetime`

  Scenario: multiple distinct values of the same `string` attribute can be set on insert

  Scenario: multiple distinct values of the same `long` attribute can be set on insert

  Scenario: multiple distinct values of the same `double` attribute can be set on insert

  Scenario: multiple distinct values of the same `boolean` attribute can be set on insert

  Scenario: multiple distinct values of the same `datetime` attribute can be set on insert

  Scenario: insert an additional role player is visible in the relation
    When graql insert
      """
      insert $p isa person, has ref 0; $r (employee: $p) isa employment, has ref 1;
      """
    When graql insert
      """
      match $r isa employment; insert $r (employer: $c) isa employment; $c isa company, has ref 2;
      """
    When the integrity is validated
    Then get answers of graql query
      """
      match $r (employer: $c, employee: $p) isa employment; get;
      """
    Then concept identifiers are
      |      | check | value |
      | REF0 | key   | ref:0 |
      | REF1 | key   | ref:1 |
      | REF2 | key   | ref:2 |
    Then uniquely identify answer concepts
      | p    | c    | r    |
      | REF0 | REF2 | REF1 |


  Scenario: insert an additional duplicate role player
    When graql insert
      """
      insert $p isa person, has ref 0; $r (employee: $p) isa employment, has ref 1;
      """
    When graql insert
      """
      match $r isa employment; $p isa person; insert $r (employee: $p) isa employment;
      """
    When the integrity is validated

    Then get answers of graql query
      """
      match $r (employee: $p, employee: $p) isa employment; get;
      """
    Then concept identifiers are
      |      | check | value |
      | REF0 | key   | ref:0 |
      | REF1 | key   | ref:1 |
    Then uniquely identify answer concepts
      | p    | r    |
      | REF0 | REF1 |


  # TODO: Create 5 scenarios in place of this one, one for each attribute value type
  Scenario: insert an attribute with a value is retrievable by the value
    When graql insert
      """
      insert $n "John" isa name, has ref 0;
      """
    When the integrity is validated
    Then get answers of graql query
      """
      match $a "John"; get;
      """
    Then concept identifiers are
      |      | check | value |
      | REF0 | key   | ref:0 |
    Then uniquely identify answer concepts
      | a    |
      | REF0 |


  # TODO - fix this; should fail but it does not!
  @ignore
  Scenario: insert an attribute that already exists throws errors when inserted with different keys
    When graql insert
      """
      insert $a "john" isa name, has ref 0;
      """
    When the integrity is validated

    Then graql insert throws
      """
      insert $a "john" isa name, has ref 1;
      """
    Then the integrity is validated


  Scenario: insert two owners of the same attribute links owners via attribute
    Given graql define
      """
      define
      person sub entity, has age;
      age sub attribute, value long;
      """
    Given the integrity is validated

    When graql insert
      """
      insert $p isa person, has age 10, has ref 0;
      """
    When the integrity is validated

    When graql insert
      """
      insert $p isa person, has age 10, has ref 1;
      """
    When the integrity is validated

    Then get answers of graql query
      """
      match
      $p1 isa person, has age $a;
      $p2 isa person, has age $a;
      $p1 != $p2;
      get $p1, $p2;
      """

    Then concept identifiers are
      |      | check | value |
      | REF0 | key   | ref:0 |
      | REF1 | key   | ref:1 |

    Then uniquely identify answer concepts
      | p1   | p2   |
      | REF0 | REF1 |
      | REF1 | REF0 |


  Scenario: insert a subtype of an attribute with same value creates a separate instance

  Scenario: insert a regex attribute throws error if not conforming to regex
    Given graql define
      """
      define
      person sub entity,
        has value;
      value sub attribute,
        value string,
        regex "\d{2}\.[true][false]";
      """
    Given the integrity is validated

    Then graql insert throws
      """
      insert
        $x isa person, has value $a, has ref 0;
        $a "10.maybe";
      """
    Then the integrity is validated


  Scenario: extend relation with duplicate role player

  Scenario: inserting duplicate keys throws on commit (? or at insert)

  Scenario: inserting disallowed role being played throws on commit (? or at insert)

  Scenario: inserting disallowed role being related throws on commit (? or at insert)

  Scenario: inserting a relation with no role players throws on commit (? or at insert)

  Scenario: match-insert includes all variable retrieved and created (?)

  Scenario: insert instance of an abstract type throws (on commit?)

  Scenario: an attribute value currently inferred by a rule can be explicitly inserted

  Scenario: a relation currently inferred by a rule can be explicitly inserted

  Scenario: match-insert returns no answers if it matches nothing

  Scenario: if any insert in a transaction fails with a syntax error, none of the inserts are performed

  Scenario: if any insert in a transaction fails with a semantic error, none of the inserts are performed

  Scenario: if any insert in a transaction fails with a `key` violation, none of the inserts are performed

