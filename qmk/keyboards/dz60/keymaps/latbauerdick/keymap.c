#include QMK_KEYBOARD_H

enum alt_layers {
  _COLEMAK,
  _QWERTY,
  _RAISE,
  _NAV,
  _ADJ
};

enum dz60_keycodes {
  COLEMAK = SAFE_RANGE,
  QWERTY
};

#define RAISE    MO(_RAISE)
#define CTL_ESC  MT(MOD_LCTL, KC_ESC)
#define RSF_SLS  MT(MOD_RSFT, KC_SLSH)
#define RSF_UP   MT(MOD_RSFT, KC_UP)
#define RSF_ENT  MT(MOD_RSFT, KC_ENT)
#define RSF_SPC  MT(MOD_RSFT, KC_SPC)
#define LSF_Z    MT(MOD_RSFT, KC_Z)
#define GUI_SPC  MT(MOD_LGUI, KC_SPC)
#define GUI_ENT  MT(MOD_LGUI, KC_ENT)
#define RGU_SPC  MT(MOD_RGUI, KC_SPC)
#define ALT_ESC  MT(MOD_LALT, KC_ESC)
#define RSE_SPC  LT(_RAISE, KC_SPC)
#define ADJ_SPC  LT(_ADJ, KC_SPC)
#define ADJ_ENT  LT(_ADJ, KC_ENT)
#define NAV_A    LT(_NAV, KC_A)
#define NAV_O    LT(_NAV, KC_O)

const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
    [_COLEMAK] = LAYOUT(
          KC_GESC, KC_1,    KC_2,    KC_3,    KC_4,    KC_5,    KC_6,    KC_7,    KC_8,    KC_9,    KC_0   , KC_MINS, KC_EQL , KC_GRV , KC_BSPC,
          KC_TAB,  KC_Q,    KC_W,    KC_F,    KC_P,    KC_B,    KC_LBRC, KC_J,    KC_L,    KC_U,    KC_Y,    KC_QUOT, KC_RBRC, KC_BSLS,
          CTL_ESC, NAV_A,   KC_R,    KC_S,    KC_T,    KC_G,    KC_SCLN, KC_M,    KC_N,    KC_E,    KC_I,    KC_O   ,          KC_ENT,
 KC_LSFT, LSF_Z  , KC_Z,    KC_X,    KC_C,    KC_D,    KC_V,    KC_SLSH, KC_K,    KC_H,    KC_COMM, KC_DOT,           RSF_ENT,          ADJ_ENT,
          KC_HYPR, ALT_ESC, GUI_ENT,          GUI_SPC,          RSF_SPC,          RSE_SPC,          RGU_SPC, KC_LEFT, KC_DOWN, KC_UP,   KC_RGHT
    ),
    [_QWERTY] = LAYOUT(
          KC_GESC, KC_1,    KC_2,    KC_3,    KC_4,    KC_5,    KC_6,    KC_7,    KC_8,    KC_9,    KC_0   , KC_MINS, KC_EQL , KC_GRV , KC_BSPC,
          KC_TAB,  KC_Q,    KC_W,    KC_E,    KC_R,    KC_Y,    KC_U   , KC_I,    KC_O,    KC_P,    KC_Y,    KC_LBRC, KC_RBRC, KC_BSPC,
          CTL_ESC, NAV_A,   KC_S,    KC_D,    KC_F,    KC_G,    KC_H,    KC_J,    KC_K,    KC_L,    KC_QUOT, KC_SCLN,          KC_ENT,
 KC_LSFT, LSF_Z  , KC_Z,    KC_X,    KC_C,    KC_V,    KC_B,    KC_N,    KC_M,    KC_COMM, KC_DOT,  KC_SLSH,          RSF_ENT,          ADJ_ENT,
          KC_HYPR, ALT_ESC, GUI_ENT,          GUI_SPC,          RSF_SPC,          RSE_SPC,          RGU_SPC, KC_LEFT, KC_DOWN, KC_UP,   KC_RGHT
    ),
    [_RAISE] = LAYOUT(
         _______, KC_F1  , KC_F2  , KC_F3  , KC_F4  , KC_F5  , KC_F6  , KC_F7  , KC_F8  , KC_F9  , KC_F10 , KC_F11 , KC_F12 , KC_F13 , _______, \
         KC_GRV , KC_EXLM, KC_AT  , KC_HASH, KC_DLR , KC_PERC, KC_RBRC, KC_CIRC, KC_AMPR, KC_ASTR, KC_PLUS, KC_LBRC, KC_RBRC, _______,          \
         _______, KC_1   , KC_2   , KC_3   , KC_4   , KC_5   , KC_QUOT, KC_6   , KC_7   , KC_8   , KC_9   , KC_0   ,          _______,          \
_______, _______, KC_LBRC, KC_RBRC, KC_MINS, KC_EQL , KC_LPRN, KC_BSLS, KC_RPRN, KC_QUOT, _______, _______,          _______,          _______, \
         _______, _______, _______,          _______,          KC_BSPC,          _______,          _______, _______, _______, _______, _______  \
    ),
    [_NAV] = LAYOUT(
          _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______,
          _______, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, XXXXXXX, KC_RBRC, S(KC_J), XXXXXXX, XXXXXXX, XXXXXXX, KC_LBRC, KC_RBRC, KC_BSLS,
          _______, XXXXXXX, KC_HOME, KC_PGUP, KC_PGDN, KC_END , KC_COLN, KC_LEFT, KC_DOWN, KC_UP  , KC_RGHT, KC_ENT ,          _______,
 _______, _______, G(KC_Z), G(KC_X), G(KC_C), G(KC_D), G(KC_V), KC_BSPC, KC_BSPC, KC_LEFT, XXXXXXX, XXXXXXX, XXXXXXX,          _______,
          _______, _______, _______,          _______,          KC_BSPC,          _______,          _______, KC_BRMD, KC_VOLD, KC_VOLU, KC_BRMU
    ),
    [_ADJ] = LAYOUT(
        KC_GRV,  KC_F1,   KC_F2,   KC_F3,   KC_F4,   KC_F5,   KC_F6,   KC_F7,   KC_F8,   KC_F9,   KC_F10,  KC_F11,  KC_F12,  _______, KC_DEL,
        _______, RGB_TOG, RGB_MOD, RGB_HUI, RGB_HUD, RGB_SAI, RGB_SAD, RGB_VAI, RGB_VAD, COLEMAK, QWERTY , _______, _______, RESET,
        _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______, _______,          _______,
        _______, _______, _______, _______, BL_DEC,  BL_TOGG, BL_INC,  BL_STEP, _______, _______, _______, _______, _______,          _______,
        _______, _______, _______,          _______,          _______,          _______,          _______, KC_BRMD, KC_VOLD, KC_VOLU, KC_BRMU
    ),
};

bool process_record_user(uint16_t keycode, keyrecord_t *record) {
  switch (keycode) {
    case QWERTY:
      if (record->event.pressed) {
        print("mode just switched to qwerty and this is a huge string\n");
        set_single_persistent_default_layer(_QWERTY);
      }
      return false;
      break;
    case COLEMAK:
      if (record->event.pressed) {
        set_single_persistent_default_layer(_COLEMAK);
      }
      return false;
      break;
  }
  return true;
}

