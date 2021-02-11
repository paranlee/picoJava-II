public class hello {

   public static int main() {
      String s = "Hello World!";
      for (int i = 0; i < s.length(); i++) {
         PicoIO.print(s.charAt(i));
      }
      PicoIO.print('\n');
      return 0;
   }


}
