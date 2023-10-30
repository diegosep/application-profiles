import os
import unittest
from application_profiles import ApplicationProfileException, ApplicationProfiles


class TestProperties(unittest.TestCase):
    def setUp(self) -> None:
        if "APP_PROFILES" in os.environ:
            del os.environ["APP_PROFILES"]

    def test_load_profile_from_default(self):
        profile = ApplicationProfiles()
        self.assertEqual(profile.properties["NAME"], "default")

    def test_load_profile_from_default_with_construct_arg(self):
        profile = ApplicationProfiles(profiles="default")
        self.assertEqual(profile.properties["NAME"], "default")

    def test_should_load_profile_from_env_var(self):
        os.environ["APP_PROFILES"] = "test"
        profile = ApplicationProfiles()
        self.assertEqual(profile.properties["NAME"], "test")

    def test_should_not_fail_when_profile_does_not_exist(self):
        ApplicationProfiles(profiles="fake")

    def test_load_profile_override_environment(self):
        os.environ["APP_PROFILES"] = "test"
        profile = ApplicationProfiles().properties

        self.assertEqual(profile["depth_1"]["depth_2"]["int"], 1)
        self.assertEqual(profile["depth_1"]["depth_2"]["string"], "string")
        self.assertEqual(profile["depth_1"]["depth_2"]["bool"], True)
        self.assertEqual(profile["depth_1"]["depth_2"]["float"], 1.1)

    def test_load_profile_append_list(self):
        os.environ["APP_PROFILES"] = "test"
        profile = ApplicationProfiles().properties

        self.assertTrue(1 in profile["depth_1"]["depth_2"]["list"])
        self.assertTrue(2 in profile["depth_1"]["depth_2"]["list"])

    def test_load_profile_append_dict(self):
        os.environ["APP_PROFILES"] = "test"
        profile = ApplicationProfiles().properties

        self.assertEqual(profile["depth_1"]["depth_2"]["map"]["key1"], "value1")
        self.assertEqual(profile["depth_1"]["depth_2"]["map"]["key2"], "value2")

    def test_load_profile_default_and_test_to_merge_values(self):
        os.environ["APP_PROFILES"] = "test"
        profile = ApplicationProfiles().properties

        self.assertIsInstance(profile["depth_1"]["depth_2"]["no_exists_on_default"], str)
        self.assertIsInstance(profile["depth_1"]["depth_2"]["no_exists_on_env"], str)
        self.assertTrue(
            profile["depth_1"]["depth_2"]["no_exists_on_default"],
            "simple",
        )
        self.assertTrue(
            profile["depth_1"]["depth_2"]["no_exists_on_env"],
            "simple",
        )

    def test_load_two_profiles_from_env_var_and_merge_values(self):
        os.environ["APP_PROFILES"] = "test,test2"
        profile = ApplicationProfiles().properties

        self.assertEqual(profile["NAME"], "test2")
        self.assertIsInstance(profile["depth_1"]["depth_2"]["no_exists_on_default"], str)
        self.assertIsInstance(profile["depth_1"]["depth_2"]["no_exists_on_env"], str)
        self.assertTrue(
            profile["depth_1"]["depth_2"]["no_exists_on_default"],
            "simple",
        )
        self.assertTrue(
            profile["depth_1"]["depth_2"]["no_exists_on_env"],
            "simple",
        )

    def test_load_two_profiles_from_constructor_arg_and_merge_values(self):
        profile = ApplicationProfiles(profiles="test,test2").properties

        self.assertEqual(profile["NAME"], "test2")
        self.assertIsInstance(profile["depth_1"]["depth_2"]["no_exists_on_default"], str)
        self.assertIsInstance(profile["depth_1"]["depth_2"]["no_exists_on_env"], str)
        self.assertTrue(
            profile["depth_1"]["depth_2"]["no_exists_on_default"],
            "simple",
        )
        self.assertTrue(
            profile["depth_1"]["depth_2"]["no_exists_on_env"],
            "simple",
        )

    def test_validate_precedence_env_var_to_load_profiles(self):
        os.environ["APP_PROFILES"] = "fake1,fake2"

        profile = ApplicationProfiles(profiles="test,test2").properties

        self.assertEqual(profile["NAME"], "default")


if __name__ == "__main__":
    unittest.main()
