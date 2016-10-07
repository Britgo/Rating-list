//   Copyright 2009 John Collins

//   This program is free software: you can redistribute it and/or modify
//   it under the terms of the GNU General Public License as published by
//   the Free Software Foundation, either version 3 of the License, or
//   (at your option) any later version.

//   This program is distributed in the hope that it will be useful,
//   but WITHOUT ANY WARRANTY; without even the implied warranty of
//   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//   GNU General Public License for more details.

//   You should have received a copy of the GNU General Public License
//   along with this program.  If not, see <http://www.gnu.org/licenses/>.

function nonblank(s)  {
   for (var i = 0;  i < s.length;  i++)  {
      var c = s.charAt(i);
      if  (c != ' '  &&  c != '\t'  &&  c != '\n')
         return  true;
   }
   return  false;
}

function okcode(s)  {
	return /^\w+$/.test(s);
}

function okname(s)  {
	return /^[A-Z][a-z]*( (Mc|O')?[A-Z][a-z]*(-[A-Z][a-z]*)?)+$/.test(s); //'
}

function okalias(s) {
   return /^[A-Za-z][-.A-Za-z0-9_]*$/.test(s);
}

function lostpw() {
	var uidv = document.getElementById('user_id');
	var l = uidv.value;
	if (!nonblank(l)) {
		 alert("No userid given");
       return;
   }
   window.open("/admin/rempwbyuid.php?uid=" + l, "Password Reminder", "width=450,height=200,resizeable=yes,scrollbars=yes");
}
