module.exports = ({ milliseconds }) => {
    sleep(milliseconds);
    console.log(milliseconds)
    function sleep(milliseconds) {
      console.log('sleep')
      const date = Date.now();
      let currentDate = null;
      do {
        currentDate = Date.now();
      } while (currentDate - date < milliseconds);
    }
}