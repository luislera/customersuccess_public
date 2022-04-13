module.exports = () => {
    sleep(3000);

    function sleep(milliseconds) {
      console.log(milliseconds)
      console.log('sleep')
      const date = Date.now();
      let currentDate = null;
      do {
        currentDate = Date.now();
      } while (currentDate - date < milliseconds);
    }
}