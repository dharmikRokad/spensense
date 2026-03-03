const admin = require("firebase-admin");
const { v4: uuidv4 } = require("uuid");

const serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

const USER_ID = "2NDK8wRELAgDximgv6soxTiAcog1";
const BANK_NAME = "HDFC Bank";
const ACCOUNT_LAST4 = "4582";

const categories = [
  "food", "shopping", "transport", "entertainment", "utilities",
  "health", "education", "travel", "fuel", "groceries",
  "emi", "investment", "salary", "transfer", "cashback",
  "recharge", "subscription", "other"
];

const foodMerchants = ["Swiggy", "Zomato", "McDonald's", "Local Cafe"];
const groceryMerchants = ["Dmart", "Big Bazaar", "Reliance Fresh"];
const fuelMerchants = ["Indian Oil", "HP Petrol Pump", "Shell"];
const shoppingMerchants = ["Amazon", "Flipkart", "Myntra"];
const transportMerchants = ["Uber", "Ola", "Metro Card"];
const utilityMerchants = ["Torrent Power", "Airtel", "Jio"];
const subscriptionMerchants = ["Netflix", "Spotify", "Amazon Prime"];

function randomItem(arr) {
  return arr[Math.floor(Math.random() * arr.length)];
}

function randomAmount(min, max) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

async function generateTransactions() {
  const batch = db.batch();
  const today = new Date();

  const totalTransactions = randomAmount(50, 70);

  for (let i = 0; i < totalTransactions; i++) {
    const daysAgo = randomAmount(0, 34);
    const date = new Date();
    date.setDate(today.getDate() - daysAgo);

    const day = date.getDay(); // 0 Sunday, 6 Saturday
    let category, amount, merchant, type = "debit";

    // Recurring patterns
    if (date.getDate() === 28) {
      category = "salary";
      amount = 25000;
      merchant = "Company Payroll";
      type = "credit";
    }
    else if (date.getDate() === 1) {
      category = "transfer";
      amount = 12000;
      merchant = "House Rent";
    }
    else if (date.getDate() === 5) {
      category = "investment";
      amount = 3000;
      merchant = "Groww SIP";
    }
    else if (date.getDate() === 10) {
      category = "emi";
      amount = 2500;
      merchant = "Bajaj Finance EMI";
    }
    else {
      // Weekend groceries more likely
      if (day === 0 || day === 6) {
        category = Math.random() > 0.4 ? "groceries" : "food";
      } else {
        category = randomItem(["food", "transport", "shopping", "fuel", "entertainment"]);
      }

      switch (category) {
        case "food":
          amount = randomAmount(150, 600);
          merchant = randomItem(foodMerchants);
          break;
        case "groceries":
          amount = randomAmount(800, 2500);
          merchant = randomItem(groceryMerchants);
          break;
        case "fuel":
          amount = randomAmount(300, 1200);
          merchant = randomItem(fuelMerchants);
          break;
        case "shopping":
          amount = randomAmount(700, 4000);
          merchant = randomItem(shoppingMerchants);
          break;
        case "transport":
          amount = randomAmount(100, 500);
          merchant = randomItem(transportMerchants);
          break;
        case "entertainment":
          amount = randomAmount(200, 1500);
          merchant = "BookMyShow";
          break;
        default:
          amount = randomAmount(100, 1000);
          merchant = "Local Merchant";
      }
    }

    const docId = uuidv4();
    const docRef = db.collection("transactions").doc(docId);

    batch.set(docRef, {
      accountLast4: ACCOUNT_LAST4,
      amount: amount,
      availableBalance: null,
      bankName: BANK_NAME,
      category: category,
      date: admin.firestore.Timestamp.fromDate(date),
      id: docId,
      isManual: Math.random() > 0.7,
      merchant: merchant,
      note: "",
      rawMessage: "AUTO-GENERATED",
      type: type,
      upiId: null,
      userId: USER_ID
    });
  }

  await batch.commit();
  console.log(`✅ ${totalTransactions} transactions generated successfully.`);
}

generateTransactions();